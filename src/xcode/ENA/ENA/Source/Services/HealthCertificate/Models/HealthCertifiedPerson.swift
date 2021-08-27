////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPerson: Codable, Equatable, Comparable {

	// MARK: - Init

	init(
		healthCertificates: [HealthCertificate],
		isPreferredPerson: Bool = false
	) {
		self.healthCertificates = healthCertificates
		self.isPreferredPerson = isPreferredPerson

		setup()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case isPreferredPerson
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = try container.decode([HealthCertificateDecodingContainer].self, forKey: .healthCertificates).compactMap { $0.healthCertificate }
		isPreferredPerson = try container.decodeIfPresent(Bool.self, forKey: .isPreferredPerson) ?? false

		setup()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(isPreferredPerson, forKey: .isPreferredPerson)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.healthCertificates == rhs.healthCertificates && lhs.isPreferredPerson == rhs.isPreferredPerson
	}

	// MARK: - Protocol Comparable

	static func < (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		let preferredPersonPrecedesNonPreferred = lhs.isPreferredPerson && !rhs.isPreferredPerson
		let haveSamePreferredStateAndAreInAlphabeticalOrder = lhs.isPreferredPerson == rhs.isPreferredPerson && lhs.name?.fullName ?? "" < rhs.name?.fullName ?? ""

		return preferredPersonPrecedesNonPreferred || haveSamePreferredStateAndAreInAlphabeticalOrder

	}

	// MARK: - Internal

	enum VaccinationState: Equatable {
		case notVaccinated
		case partiallyVaccinated
		case fullyVaccinated(daysUntilCompleteProtection: Int)
		case completelyProtected(expirationDate: Date)
	}

	let objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

	@DidSetPublished var healthCertificates: [HealthCertificate] {
		didSet {
			if healthCertificates != oldValue {
				updateVaccinationState()
				updateMostRelevantHealthCertificate()
				updateHealthCertificateSubscriptions(for: healthCertificates)

				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var isPreferredPerson: Bool {
		didSet {
			if isPreferredPerson != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var vaccinationState: VaccinationState = .notVaccinated {
		didSet {
			if vaccinationState != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var mostRelevantHealthCertificate: HealthCertificate? {
		didSet {
			if mostRelevantHealthCertificate != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var gradientType: GradientView.GradientType = .lightBlue(withStars: true)

	var name: Name? {
		healthCertificates.first?.name
	}

	var dateOfBirth: String? {
		healthCertificates.first?.dateOfBirth
	}

	var vaccinationCertificates: [HealthCertificate] {
		healthCertificates.filter { $0.vaccinationEntry != nil }
	}

	var testCertificates: [HealthCertificate] {
		healthCertificates.filter { $0.testEntry != nil }
	}

	@objc
	func triggerMostRelevantCertificateUpdate() {
		updateMostRelevantHealthCertificate()
		scheduleMostRelevantCertificateTimer()
	}

	// internal for testing
	var recoveredVaccinationCertificate: HealthCertificate? {
		return vaccinationCertificates.first { certificate in
			guard let vaccinationEntry = certificate.vaccinationEntry,
				  vaccinationEntry.totalSeriesOfDoses == 1,
				  vaccinationEntry.doseNumber == 1,
				  VaccinationProductType(value: vaccinationEntry.vaccineMedicinalProduct) != .other else {
				return false
			}
			return true
		}
	}

	var completeBoosterVaccinationProtectionDate: Date? {
		healthCertificates.compactMap({ healthCertificate -> Date? in
			guard let vaccinationEntry = healthCertificate.vaccinationEntry else {
				return nil
			}
			// look for a booster date -> AstraZeneca, Moderna and BioNTech if dose is 3 or more, Johnson & Johnson if dose is 2 or more
			let product = vaccinationEntry.vaccineMedicinalProduct
			switch VaccinationProductType(value: product) {
			case .biontech  where vaccinationEntry.doseNumber > 2,
				 .moderna where vaccinationEntry.doseNumber > 2,
				 .astraZeneca where vaccinationEntry.doseNumber > 2,
				 .johnsonAndJohnson where vaccinationEntry.doseNumber > 1:
				return vaccinationEntry.localVaccinationDate
			case .other:
				return nil
			default:
				return nil
			}
		})
		.min()
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()
	private var healthCertificateSubscriptions = Set<AnyCancellable>()
	private var mostRelevantCertificateTimer: Timer?

	private var completeVaccinationProtectionDate: Date? {
		if let completeBoosterVaccinationProtectionDate = self.completeBoosterVaccinationProtectionDate {
			return completeBoosterVaccinationProtectionDate
		} else if let recoveredVaccinatedCertificate = recoveredVaccinationCertificate,
		   let vaccinationDateString = recoveredVaccinatedCertificate.vaccinationEntry?.dateOfVaccination {
			// if recovery date found -> use it
			return ISO8601DateFormatter.justLocalDateFormatter.date(from: vaccinationDateString)
		} else if let lastVaccination = vaccinationCertificates.filter({ $0.vaccinationEntry?.isLastDoseInASeries ?? false }).max(),
				  let vaccinationDateString = lastVaccination.vaccinationEntry?.dateOfVaccination,
				  let vaccinationDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: vaccinationDateString) {
			// else if last vaccination date -> use it
			return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 15, to: vaccinationDate)
		} else {
			// no date -> completeVaccinationProtectionDate is nil
			return nil
		}
	}

	private var vaccinationExpirationDate: Date? {
		guard let lastVaccination = vaccinationCertificates.last(where: { $0.vaccinationEntry?.isLastDoseInASeries ?? false }) else {
			return nil
		}

		return lastVaccination.expirationDate
	}

	private func setup() {
		updateVaccinationState()
		updateMostRelevantHealthCertificate()
		updateHealthCertificateSubscriptions(for: healthCertificates)

		subscribeToNotifications()
		scheduleMostRelevantCertificateTimer()
	}

	private func updateHealthCertificateSubscriptions(for healthCertificates: [HealthCertificate]) {
		healthCertificateSubscriptions = []

		healthCertificates.forEach { healthCertificate in
			healthCertificate.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }

					self.updateVaccinationState()
					self.updateMostRelevantHealthCertificate()

					self.objectDidChange.send(self)
				}
				.store(in: &healthCertificateSubscriptions)
		}
	}

	private func updateVaccinationState() {
		if let completeVaccinationProtectionDate = completeVaccinationProtectionDate,
		   let vaccinationExpirationDate = vaccinationExpirationDate {
			if completeVaccinationProtectionDate > Date() {
				let startOfToday = Calendar.autoupdatingCurrent.startOfDay(for: Date())
				guard let daysUntilCompleteProtection = Calendar.autoupdatingCurrent.dateComponents([.day], from: startOfToday, to: completeVaccinationProtectionDate).day else {
					fatalError("Could not get days until complete protection")
				}

				vaccinationState = .fullyVaccinated(daysUntilCompleteProtection: daysUntilCompleteProtection)
			} else {
				vaccinationState = .completelyProtected(expirationDate: vaccinationExpirationDate)
			}
		} else if !vaccinationCertificates.isEmpty {
			vaccinationState = .partiallyVaccinated
		} else {
			vaccinationState = .notVaccinated
		}
	}

	private func subscribeToNotifications() {
		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.updateVaccinationState()
			}
			.store(in: &subscriptions)

		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.significantTimeChangeNotification)
			.sink { [weak self] _ in
				self?.updateVaccinationState()
				self?.scheduleMostRelevantCertificateTimer()
			}
			.store(in: &subscriptions)
	}

	private func scheduleMostRelevantCertificateTimer() {
		mostRelevantCertificateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let nextMostRelevantCertificateChangeDate = healthCertificates.nextMostRelevantChangeDate else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(triggerMostRelevantCertificateUpdate), name: UIApplication.didBecomeActiveNotification, object: nil)

		mostRelevantCertificateTimer = Timer(fireAt: nextMostRelevantCertificateChangeDate, interval: 0, target: self, selector: #selector(updateMostRelevantHealthCertificate), userInfo: nil, repeats: false)

		guard let mostRelevantCertificateTimer = mostRelevantCertificateTimer else { return }
		RunLoop.current.add(mostRelevantCertificateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		mostRelevantCertificateTimer?.invalidate()
	}

	@objc
	private func updateMostRelevantHealthCertificate() {
		mostRelevantHealthCertificate = healthCertificates.mostRelevant
	}
}
