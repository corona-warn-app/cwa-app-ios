////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit
import class CertLogic.Rule

class HealthCertifiedPerson: Codable, Equatable, Comparable {

	// MARK: - Init

	init(
		healthCertificates: [HealthCertificate],
		isPreferredPerson: Bool = false,
		boosterRule: Rule? = nil,
		isNewBoosterRule: Bool = false
	) {
		self.healthCertificates = healthCertificates
		self.isPreferredPerson = isPreferredPerson
		self.boosterRule = boosterRule
		self.isNewBoosterRule = isNewBoosterRule

		setup()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case isPreferredPerson
		case boosterRule
		case isNewBoosterRule
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = []
		isPreferredPerson = try container.decodeIfPresent(Bool.self, forKey: .isPreferredPerson) ?? false
		boosterRule = try container.decodeIfPresent(Rule.self, forKey: .boosterRule)
		isNewBoosterRule = try container.decodeIfPresent(Bool.self, forKey: .isNewBoosterRule) ?? false

		let decodingContainers = try container.decode([HealthCertificateDecodingContainer].self, forKey: .healthCertificates)

		decodingContainers.forEach {
			do {
				let healthCertificate = try HealthCertificate(
					base45: $0.base45,
					validityState: $0.validityState ?? .valid,
					didShowInvalidNotification: $0.didShowInvalidNotification ?? false,
					didShowBlockedNotification: $0.didShowBlockedNotification ?? false,
					isNew: $0.isNew ?? false,
					isValidityStateNew: $0.isValidityStateNew ?? false
				)

				healthCertificates.append(healthCertificate)
			} catch {
				let decodingFailedHealthCertificate = DecodingFailedHealthCertificate(
					base45: $0.base45,
					error: error
				)

				decodingFailedHealthCertificates.append(decodingFailedHealthCertificate)
			}
		}

		setup()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(isPreferredPerson, forKey: .isPreferredPerson)
		try container.encode(boosterRule, forKey: .boosterRule)
		try container.encode(isNewBoosterRule, forKey: .isNewBoosterRule)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.healthCertificates == rhs.healthCertificates &&
		lhs.isPreferredPerson == rhs.isPreferredPerson &&
		lhs.boosterRule == rhs.boosterRule &&
		lhs.isNewBoosterRule == rhs.isNewBoosterRule
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
			// States and subscriptions only need to be updated if certificates were added or removed
			if healthCertificates.map({ $0.uniqueCertificateIdentifier }) != oldValue.map({ $0.uniqueCertificateIdentifier }) {
				updateVaccinationState()
				updateAdmissionState()
				updateMostRelevantHealthCertificate()
				updateHealthCertificateSubscriptions(for: healthCertificates)
			}

			// objectDidChange is triggered for changes in existing health certificates as well
			if healthCertificates != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var decodingFailedHealthCertificates: [DecodingFailedHealthCertificate] = []

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

	@DidSetPublished var admissionState: HealthCertifiedPersonAdmissionState = .other {
		didSet {
			if admissionState != oldValue {
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

	@DidSetPublished var gradientType: GradientView.GradientType = .lightBlue

	@DidSetPublished var boosterRule: Rule? {
		didSet {
			if boosterRule != oldValue {
				isNewBoosterRule = boosterRule != nil
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var isNewBoosterRule: Bool {
		didSet {
			if isNewBoosterRule != oldValue {
				objectDidChange.send(self)
			}
		}
	}

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

	var unseenNewsCount: Int {
		let certificatesWithNews = healthCertificates.filter { $0.isNew || $0.isValidityStateNew }

		return certificatesWithNews.count + (boosterRule != nil && isNewBoosterRule ? 1 : 0)
	}

	@objc
	func triggerMostRelevantCertificateUpdate() {
		updateMostRelevantHealthCertificate()
		scheduleMostRelevantCertificateTimer()
	}

	var recoveredVaccinationCertificate: HealthCertificate? {
		return vaccinationCertificates.first { $0.vaccinationEntry?.isRecoveredVaccination ?? false }
	}

	var completeBoosterVaccinationProtectionDate: Date? {
		healthCertificates
			.filter { $0.vaccinationEntry?.isBoosterVaccination ?? false }
			.compactMap { $0.vaccinationEntry?.localVaccinationDate }
			.max()
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()
	private var healthCertificateSubscriptions = Set<AnyCancellable>()
	private var mostRelevantCertificateTimer: Timer?

	private var completeVaccinationProtectionDate: Date? {
		if let recoveredVaccinatedCertificate = recoveredVaccinationCertificate,
		   let vaccinationDateString = recoveredVaccinatedCertificate.vaccinationEntry?.dateOfVaccination {
			// if recovery vaccination date found
			return ISO8601DateFormatter.justLocalDateFormatter.date(from: vaccinationDateString)
		} else if let completeBoosterVaccinationProtectionDate = self.completeBoosterVaccinationProtectionDate {
			// if booster vaccination date found
			return completeBoosterVaccinationProtectionDate
		} else if let lastVaccination = vaccinationCertificates.filter({ $0.vaccinationEntry?.isLastDoseInASeries ?? false &&
			$0.ageInDays ?? 0 > 14 }).max(), let vaccinationDate = lastVaccination.vaccinationEntry?.localVaccinationDate {
			// if series completion vaccination date found with > 14 days
			return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 15, to: vaccinationDate)
		} else if let lastVaccination = vaccinationCertificates.filter({ $0.vaccinationEntry?.isLastDoseInASeries ?? false && $0.ageInDays ?? 0 <= 14 }).max(), let vaccinationDate = lastVaccination.vaccinationEntry?.localVaccinationDate {
			// if series completion vaccination date found <= 14 days
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
		updateAdmissionState()
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
					self.updateAdmissionState()
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

	private func updateAdmissionState() {
		admissionState = healthCertificates.admissionState
	}

	private func subscribeToNotifications() {
		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.updateVaccinationState()
				self?.updateAdmissionState()
			}
			.store(in: &subscriptions)

		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.significantTimeChangeNotification)
			.sink { [weak self] _ in
				self?.updateVaccinationState()
				self?.updateAdmissionState()
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
