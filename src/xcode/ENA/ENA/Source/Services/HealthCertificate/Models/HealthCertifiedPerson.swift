////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPerson: OpenCombine.ObservableObject, Codable, Equatable {

	// MARK: - Init

	init(healthCertificates: [HealthCertificate], proofCertificate: ProofCertificate?) {
		self.healthCertificates = healthCertificates
		self.proofCertificate = proofCertificate

		setupExpiredPublisher(for: proofCertificate)
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case proofCertificate
		case lastProofCertificateUpdate
		case proofCertificateUpdatePending
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)
		proofCertificate = try container.decode(ProofCertificate.self, forKey: .proofCertificate)
		lastProofCertificateUpdate = try container.decodeIfPresent(Date.self, forKey: .lastProofCertificateUpdate)
		proofCertificateUpdatePending = try container.decode(Bool.self, forKey: .proofCertificateUpdatePending)

		setupExpiredPublisher(for: proofCertificate)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(proofCertificate, forKey: .proofCertificate)
		try container.encode(lastProofCertificateUpdate, forKey: .lastProofCertificateUpdate)
		try container.encode(proofCertificateUpdatePending, forKey: .proofCertificateUpdatePending)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.proofCertificate == rhs.proofCertificate && lhs.healthCertificates == rhs.healthCertificates
	}

	// MARK: - Internal

	@OpenCombine.Published var healthCertificates: [HealthCertificate] {
		didSet {
			objectDidChange.send(self)
		}
	}

	@OpenCombine.Published var proofCertificate: ProofCertificate? {
		didSet {
			setupExpiredPublisher(for: proofCertificate)
			objectDidChange.send(self)
		}
	}

	var objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

	@OpenCombine.Published var hasValidProofCertificate: Bool = false {
		didSet {
			objectDidChange.send(self)
		}
	}

	var fullName: String? {
		proofCertificate?.fullName ?? healthCertificates.first?.name.fullName
	}

	var dateOfBirth: String? {
		proofCertificate?.dateOfBirth ?? healthCertificates.first?.dateOfBirth
	}

	// LAST_SUCCESSFUL_PC_RUN_TIMESTAMP
	var lastProofCertificateUpdate: Date?

	// PC_RUN_PENDING
	var proofCertificateUpdatePending: Bool = false

	var shouldAutomaticallyUpdateProofCertificate: Bool {
		if proofCertificateUpdatePending {
			return true
		}

		guard let lastProofCertificateUpdate = lastProofCertificateUpdate else {
			return true
		}

		return !Calendar.utc().isDateInToday(lastProofCertificateUpdate)
	}

	func removeProofCertificateIfExpired() {
		if proofCertificate?.isExpired == true {
			proofCertificate = nil
		}
	}

	// MARK: - Private

	private var expiredStateTimer: Timer?

	private func setupExpiredPublisher(for proofCertificate: ProofCertificate?) {
		guard let proofCertificate = proofCertificate else {
			hasValidProofCertificate = false
			return
		}

		hasValidProofCertificate = !proofCertificate.isExpired

		if hasValidProofCertificate {
			scheduleExpiredStateTimer(for: proofCertificate)
		}
	}

	private func scheduleExpiredStateTimer(for proofCertificate: ProofCertificate) {
		expiredStateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		expiredStateTimer = Timer(fireAt: proofCertificate.expirationDate, interval: 0, target: self, selector: #selector(updateFromTimer), userInfo: nil, repeats: false)

		guard let expiredStateTimer = expiredStateTimer else { return }
		RunLoop.current.add(expiredStateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		expiredStateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateFromTimer()

		setupExpiredPublisher(for: proofCertificate)
	}

	@objc
	private func updateFromTimer() {
		guard let proofCertificate = proofCertificate else {
			return
		}

		hasValidProofCertificate = !proofCertificate.isExpired
	}

}
