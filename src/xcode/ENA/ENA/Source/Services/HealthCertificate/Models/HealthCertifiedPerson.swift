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
		isNewBoosterRule: Bool = false,
		dccWalletInfo: DCCWalletInfo? = nil
	) {
		self.healthCertificates = healthCertificates
		self.isPreferredPerson = isPreferredPerson
		self.boosterRule = boosterRule
		self.isNewBoosterRule = isNewBoosterRule
		self.dccWalletInfo = dccWalletInfo

		setup()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case decodingFailedHealthCertificates
		case isPreferredPerson
		case boosterRule
		case isNewBoosterRule
		case dccWalletInfo
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = []
		decodingFailedHealthCertificates = try container.decodeIfPresent([DecodingFailedHealthCertificate].self, forKey: .decodingFailedHealthCertificates) ?? []
		isPreferredPerson = try container.decodeIfPresent(Bool.self, forKey: .isPreferredPerson) ?? false
		boosterRule = try container.decodeIfPresent(Rule.self, forKey: .boosterRule)
		isNewBoosterRule = try container.decodeIfPresent(Bool.self, forKey: .isNewBoosterRule) ?? false
		dccWalletInfo = try container.decodeIfPresent(DCCWalletInfo.self, forKey: .dccWalletInfo)

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
				Log.error("Decoding certificate failed on first attempt \(private: $0.base45)", error: error)

				let decodingFailedHealthCertificate = DecodingFailedHealthCertificate(
					base45: $0.base45,
					validityState: $0.validityState ?? .valid,
					didShowInvalidNotification: $0.didShowInvalidNotification ?? false,
					didShowBlockedNotification: $0.didShowBlockedNotification ?? false,
					isNew: $0.isNew ?? false,
					isValidityStateNew: $0.isValidityStateNew ?? false,
					error: error
				)

				decodingFailedHealthCertificates.append(decodingFailedHealthCertificate)
			}
		}

		attemptToRestoreDecodingFailedHealthCertificates()
		setup()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(decodingFailedHealthCertificates, forKey: .decodingFailedHealthCertificates)
		try container.encode(isPreferredPerson, forKey: .isPreferredPerson)
		try container.encode(boosterRule, forKey: .boosterRule)
		try container.encode(isNewBoosterRule, forKey: .isNewBoosterRule)
		try container.encode(dccWalletInfo, forKey: .dccWalletInfo)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.healthCertificates == rhs.healthCertificates &&
		lhs.isPreferredPerson == rhs.isPreferredPerson &&
		lhs.boosterRule == rhs.boosterRule &&
		lhs.isNewBoosterRule == rhs.isNewBoosterRule &&
		lhs.dccWalletInfo == rhs.dccWalletInfo
	}

	// MARK: - Protocol Comparable

	static func < (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		let preferredPersonPrecedesNonPreferred = lhs.isPreferredPerson && !rhs.isPreferredPerson
		let haveSamePreferredStateAndAreInAlphabeticalOrder = lhs.isPreferredPerson == rhs.isPreferredPerson && lhs.name?.fullName ?? "" < rhs.name?.fullName ?? ""

		return preferredPersonPrecedesNonPreferred || haveSamePreferredStateAndAreInAlphabeticalOrder

	}

	// MARK: - Internal

	let objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

	@DidSetPublished var healthCertificates: [HealthCertificate] {
		didSet {
			// States and subscriptions only need to be updated if certificates were added or removed
			if healthCertificates.map({ $0.uniqueCertificateIdentifier }) != oldValue.map({ $0.uniqueCertificateIdentifier }) {
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
			if dccWalletInfo?.boosterNotification.identifier != oldValue?.boosterNotification.identifier {
				isNewBoosterRule = boosterRule != nil
			}

			if dccWalletInfo != oldValue {
				objectDidChange.send(self)
			}
		}
	}

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

	func healthCertificate(for reference: DCCCertificateReference) -> HealthCertificate? {
		healthCertificates.first { $0.base45 == reference.barcodeData }
	}

	var mostRelevantHealthCertificate: HealthCertificate? {
		(dccWalletInfo?.mostRelevantCertificate).flatMap { self.healthCertificate(for: $0.certificateRef) } ?? healthCertificates.fallback
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
		if dccWalletInfo == nil {
			updateDCCWalletInfo()
		}

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

		guard let nextMostRelevantCertificateChangeDate = dccWalletInfo?.validUntil else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(scheduleDCCWalletInfoUpdateTimer), name: UIApplication.didBecomeActiveNotification, object: nil)

		dccWalletInfoUpdateTimer = Timer(fireAt: nextMostRelevantCertificateChangeDate, interval: 0, target: self, selector: #selector(updateDCCWalletInfo), userInfo: nil, repeats: false)

		guard let mostRelevantCertificateTimer = dccWalletInfoUpdateTimer else { return }
		RunLoop.current.add(mostRelevantCertificateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		dccWalletInfoUpdateTimer?.invalidate()
	}

	@objc
	private func updateDCCWalletInfo() {

	}

}
