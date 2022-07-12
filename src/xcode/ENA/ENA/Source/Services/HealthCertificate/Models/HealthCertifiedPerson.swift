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
		dccWalletInfo: DCCWalletInfo? = nil,
		mostRecentWalletInfoUpdateFailed: Bool = false,
		boosterRule: Rule? = nil,
		isNewBoosterRule: Bool = false,
		isNewCertificateReissuance: Bool = false,
		isAdmissionStateChanged: Bool = false
	) {
		self.healthCertificates = healthCertificates
		self.isPreferredPerson = isPreferredPerson
		self.dccWalletInfo = dccWalletInfo
		self.mostRecentWalletInfoUpdateFailed = mostRecentWalletInfoUpdateFailed
		self.boosterRule = boosterRule
		self.isNewBoosterRule = isNewBoosterRule
		self.isNewCertificateReissuance = isNewCertificateReissuance
		self.isAdmissionStateChanged = isAdmissionStateChanged

		setup()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case decodingFailedHealthCertificates
		case isPreferredPerson
		case dccWalletInfo
		case mostRecentWalletInfoUpdateFailed
		case boosterRule
		case isNewBoosterRule
		case isNewCertificateReissuance
		case isAdmissionStateChanged
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		var healthCertificates = [HealthCertificate]()
		var decodingFailedHealthCertificates = try container.decodeIfPresent([DecodingFailedHealthCertificate].self, forKey: .decodingFailedHealthCertificates) ?? []
		isPreferredPerson = try container.decodeIfPresent(Bool.self, forKey: .isPreferredPerson) ?? false
		dccWalletInfo = try container.decodeIfPresent(DCCWalletInfo.self, forKey: .dccWalletInfo)
		mostRecentWalletInfoUpdateFailed = try container.decodeIfPresent(Bool.self, forKey: .mostRecentWalletInfoUpdateFailed) ?? false
		boosterRule = try container.decodeIfPresent(Rule.self, forKey: .boosterRule)
		isNewBoosterRule = try container.decodeIfPresent(Bool.self, forKey: .isNewBoosterRule) ?? false
		isNewCertificateReissuance = try container.decodeIfPresent(Bool.self, forKey: .isNewCertificateReissuance) ?? false
		isAdmissionStateChanged = try container.decodeIfPresent(Bool.self, forKey: .isAdmissionStateChanged) ?? false
		
		let decodingContainers = try container.decode([HealthCertificateDecodingContainer].self, forKey: .healthCertificates)

		for decodingContainer in decodingContainers {
			do {
				let healthCertificate = try HealthCertificate(
					base45: decodingContainer.base45,
					validityState: decodingContainer.validityState ?? .valid,
					didShowInvalidNotification: decodingContainer.didShowInvalidNotification ?? false,
					didShowBlockedNotification: decodingContainer.didShowBlockedNotification ?? false,
					didShowRevokedNotification: decodingContainer.didShowRevokedNotification ?? false,
					isNew: decodingContainer.isNew ?? false,
					isValidityStateNew: decodingContainer.isValidityStateNew ?? false,
					revocationEntries: decodingContainer.revocationEntries
				)

				healthCertificates.append(healthCertificate)
			} catch {
				Log.error("Decoding certificate failed on first attempt \(private: decodingContainer.base45)", error: error)

				let decodingFailedHealthCertificate = DecodingFailedHealthCertificate(
					base45: decodingContainer.base45,
					validityState: decodingContainer.validityState ?? .valid,
					didShowInvalidNotification: decodingContainer.didShowInvalidNotification ?? false,
					didShowBlockedNotification: decodingContainer.didShowBlockedNotification ?? false,
					didShowRevokedNotification: decodingContainer.didShowRevokedNotification ?? false,
					isNew: decodingContainer.isNew ?? false,
					isValidityStateNew: decodingContainer.isValidityStateNew ?? false,
					revocationEntries: decodingContainer.revocationEntries,
					error: error
				)

				decodingFailedHealthCertificates.append(decodingFailedHealthCertificate)
			}
		}

		self.healthCertificates = healthCertificates
		self.decodingFailedHealthCertificates = decodingFailedHealthCertificates

		attemptToRestoreDecodingFailedHealthCertificates()
		setup()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(decodingFailedHealthCertificates, forKey: .decodingFailedHealthCertificates)
		try container.encode(isPreferredPerson, forKey: .isPreferredPerson)
		try container.encode(dccWalletInfo, forKey: .dccWalletInfo)
		try container.encode(mostRecentWalletInfoUpdateFailed, forKey: .mostRecentWalletInfoUpdateFailed)
		try container.encode(boosterRule, forKey: .boosterRule)
		try container.encode(isNewBoosterRule, forKey: .isNewBoosterRule)
		try container.encode(isNewCertificateReissuance, forKey: .isNewCertificateReissuance)
		try container.encode(isAdmissionStateChanged, forKey: .isAdmissionStateChanged)

	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs === rhs
	}

	// MARK: - Protocol Comparable

	static func < (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		let preferredPersonPrecedesNonPreferred = lhs.isPreferredPerson && !rhs.isPreferredPerson
		let haveSamePreferredStateAndAreInAlphabeticalOrder = lhs.isPreferredPerson == rhs.isPreferredPerson && lhs.name?.fullName ?? "" < rhs.name?.fullName ?? ""

		return preferredPersonPrecedesNonPreferred || haveSamePreferredStateAndAreInAlphabeticalOrder
	}

	// MARK: - Internal

	let objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()
	let dccWalletInfoUpdateRequest = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

	let queue = DispatchQueue(label: "com.sap.HealthCertifiedPerson.\(NSUUID().uuidString)")

	@DidSetPublished var healthCertificates: [HealthCertificate] {
		didSet {
			// States and subscriptions only need to be updated if certificates were added or removed
			if healthCertificates.map({ $0.base45 }) != oldValue.map({ $0.base45 }) {
				updateDCCWalletInfo()
				updateHealthCertificateSubscriptions(for: healthCertificates)
			}

			// objectDidChange is triggered for changes in existing health certificates as well
			if healthCertificates != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var decodingFailedHealthCertificates: [DecodingFailedHealthCertificate] = [] {
		didSet {
			if decodingFailedHealthCertificates != oldValue {
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

	@DidSetPublished var gradientType: GradientView.GradientType = .lightBlue

	@DidSetPublished var dccWalletInfo: DCCWalletInfo? {
		didSet {
			/// Check if booster rule was set before transition to DCCWalletInfo to not send out a second notification
			let oldIdentifier = boosterRule?.identifier ?? oldValue?.boosterNotification.identifier
			if dccWalletInfo?.boosterNotification.identifier != oldIdentifier {
				isNewBoosterRule = dccWalletInfo?.boosterNotification.identifier != nil
			}

			var oldReissuanceIdentifier = oldValue?.certificateReissuance?.reissuanceDivision.identifier
			if let oldCertificateReissuance = oldValue?.certificateReissuance, oldCertificateReissuance.reissuanceDivision.identifier == nil {
				oldReissuanceIdentifier = "renew"
			}
			if dccWalletInfo?.certificateReissuance?.reissuanceDivision.identifier != oldReissuanceIdentifier {
				isNewCertificateReissuance = dccWalletInfo?.certificateReissuance?.reissuanceDivision.visible == true
			}

			if oldValue?.admissionState.identifier != nil && dccWalletInfo?.admissionState.identifier != oldValue?.admissionState.identifier {
				isAdmissionStateChanged = dccWalletInfo?.admissionState.identifier != nil
			}

			if dccWalletInfo != nil {
				/// Once initial dccWalletInfo was calculated, legacy boosterRule property can be set to nil
				boosterRule = nil
			}

			if dccWalletInfo != oldValue {
				scheduleDCCWalletInfoUpdateTimer()
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var mostRecentWalletInfoUpdateFailed: Bool {
		didSet {
			if mostRecentWalletInfoUpdateFailed != oldValue {
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

	@DidSetPublished var isNewCertificateReissuance: Bool {
		didSet {
			if isNewCertificateReissuance != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var isAdmissionStateChanged: Bool {
		didSet {
			if isAdmissionStateChanged != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	/// Only kept around for migration purposes so people that already have a booster rule set don't get a second notification for the same rule
	var boosterRule: Rule? {
		didSet {
			if boosterRule != oldValue {
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

	/// Not a constant identifier, can change if certificates are added or removed!
	var identifier: String? {
		guard let name = name?.standardizedName, let dateOfBirth = dateOfBirth else {
			return nil
		}

		return ENAHasher.sha256(name + dateOfBirth)
	}

	var vaccinationCertificates: [HealthCertificate] {
		healthCertificates.filter { $0.vaccinationEntry != nil }
	}

	var testCertificates: [HealthCertificate] {
		healthCertificates.filter { $0.testEntry != nil }
	}

	var unseenNewsCount: Int {
		let certificatesWithNews = healthCertificates.filter { $0.isNew || $0.isValidityStateNew }

		return certificatesWithNews.count
			+ (isAdmissionStateChanged ? 1 : 0)
			+ (dccWalletInfo?.boosterNotification.identifier != nil && isNewBoosterRule ? 1 : 0)
			+ (dccWalletInfo?.certificateReissuance?.reissuanceDivision.visible == true && isNewCertificateReissuance ? 1 : 0)
	}

	var mostRelevantHealthCertificate: HealthCertificate? {
		(dccWalletInfo?.mostRelevantCertificate).flatMap { self.healthCertificate(for: $0.certificateRef) } ?? healthCertificates.fallback
	}

	var needsDCCWalletInfoUpdate: Bool {
		let now = Date()

		return dccWalletInfo == nil || mostRecentWalletInfoUpdateFailed || (dccWalletInfo?.validUntil ?? now) < now
	}
	
	func healthCertificate(for reference: DCCCertificateReference) -> HealthCertificate? {
		healthCertificates.first { $0.base45 == reference.barcodeData }
	}

	func attemptToRestoreDecodingFailedHealthCertificates() {
		decodingFailedHealthCertificates.forEach { certificate in
			// In case the certificate was added manually by the user again
			if healthCertificates.contains(where: { $0.base45 == certificate.base45 }) {
				decodingFailedHealthCertificates.removeAll { $0.base45 == certificate.base45 }
				return
			}

			do {
				let healthCertificate = try HealthCertificate(
					base45: certificate.base45,
					validityState: certificate.validityState,
					didShowInvalidNotification: certificate.didShowInvalidNotification,
					didShowBlockedNotification: certificate.didShowBlockedNotification,
					didShowRevokedNotification: certificate.didShowRevokedNotification,
					isNew: certificate.isNew,
					isValidityStateNew: certificate.isValidityStateNew
				)

				healthCertificates.append(healthCertificate)
				decodingFailedHealthCertificates.removeAll { $0.base45 == certificate.base45 }
			} catch {
				certificate.error = error

				Log.error("Decoding certificate failed repeatedly for \(private: certificate.base45)", error: error)
			}
		}
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()
	private var healthCertificateSubscriptions = Set<AnyCancellable>()
	private var dccWalletInfoUpdateTimer: Timer?

	private func setup() {
		updateHealthCertificateSubscriptions(for: healthCertificates)
		scheduleDCCWalletInfoUpdateTimer()
	}

	private func updateHealthCertificateSubscriptions(for healthCertificates: [HealthCertificate]) {
		healthCertificateSubscriptions = []

		healthCertificates.forEach { healthCertificate in
			healthCertificate.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }

					self.objectDidChange.send(self)
				}
				.store(in: &healthCertificateSubscriptions)
		}
	}

	@objc
	private func scheduleDCCWalletInfoUpdateTimer() {
		dccWalletInfoUpdateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let dccWalletInfoExpirationDate = dccWalletInfo?.validUntil else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(scheduleDCCWalletInfoUpdateTimer), name: UIApplication.didBecomeActiveNotification, object: nil)

		dccWalletInfoUpdateTimer = Timer(fireAt: dccWalletInfoExpirationDate, interval: 0, target: self, selector: #selector(updateDCCWalletInfo), userInfo: nil, repeats: false)

		guard let dccWalletInfoUpdateTimer = dccWalletInfoUpdateTimer else { return }
		RunLoop.main.add(dccWalletInfoUpdateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		dccWalletInfoUpdateTimer?.invalidate()
	}

	@objc
	private func updateDCCWalletInfo() {
		dccWalletInfoUpdateRequest.send(self)
	}

}
