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

		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)
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
		lhs.healthCertificates == rhs.healthCertificates
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

	@DidSetPublished var healthCertificates: [HealthCertificate] {
		didSet {
			if healthCertificates != oldValue {
				updateVaccinationState()
				updateMostRelevantHealthCertificate()

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

	var objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

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

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()
	private var mostRelevantCertificateTimer: Timer?

	private var completeVaccinationProtectionDate: Date? {
		guard
			let lastVaccination = vaccinationCertificates.filter({ $0.vaccinationEntry?.isLastDoseInASeries ?? false }).max(),
			let vaccinationDateString = lastVaccination.vaccinationEntry?.dateOfVaccination,
			let vaccinationDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: vaccinationDateString)
		else {
			return nil
		}

		return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 15, to: vaccinationDate)
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

		subscribeToNotifications()
		scheduleMostRelevantCertificateTimer()
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
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		mostRelevantCertificateTimer = Timer(fireAt: nextMostRelevantCertificateChangeDate, interval: 0, target: self, selector: #selector(updateMostRelevantHealthCertificate), userInfo: nil, repeats: false)

		guard let mostRelevantCertificateTimer = mostRelevantCertificateTimer else { return }
		RunLoop.current.add(mostRelevantCertificateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		mostRelevantCertificateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateMostRelevantHealthCertificate()
		scheduleMostRelevantCertificateTimer()
	}

	@objc
	private func updateMostRelevantHealthCertificate() {
		mostRelevantHealthCertificate = healthCertificates.mostRelevant
	}

}
