////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPerson: Codable, Equatable {

	// MARK: - Init

	init(healthCertificates: [HealthCertificate]) {
		self.healthCertificates = healthCertificates

		updateVaccinationState()
		subscribeToNotifications()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)

		updateVaccinationState()
		subscribeToNotifications()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.healthCertificates == rhs.healthCertificates
	}

	// MARK: - Internal

	enum VaccinationState: Equatable {
		case partiallyVaccinated
		case fullyVaccinated(daysUntilCompleteProtection: Int)
		case completelyProtected
	}

	var healthCertificates: [HealthCertificate] {
		didSet {
			updateVaccinationState()

			objectDidChange.send(self)
		}
	}

	@OpenCombine.Published var vaccinationState: VaccinationState = .partiallyVaccinated {
		didSet {
			objectDidChange.send(self)
		}
	}

	var objectDidChange = OpenCombine.PassthroughSubject<HealthCertifiedPerson, Never>()

	var fullName: String? {
		healthCertificates.first?.name.fullName
	}

	var dateOfBirth: String? {
		healthCertificates.first?.dateOfBirth
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private var completeVaccinationProtectionDate: Date? {
		guard
			let lastVaccination = healthCertificates.last, lastVaccination.isLastDoseInASeries,
			let vaccinationDateString = lastVaccination.vaccinationCertificates.first?.dateOfVaccination,
			let vaccinationDate = ISO8601DateFormatter.contactDiaryFormatter.date(from: vaccinationDateString)
		else {
			return nil
		}

		return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 14, to: vaccinationDate)
	}

	private func updateVaccinationState() {
		if let completeVaccinationProtectionDate = completeVaccinationProtectionDate {
			if completeVaccinationProtectionDate > Date() {
				let startOfToday = Calendar.autoupdatingCurrent.startOfDay(for: Date())
				guard let daysUntilCompleteProtection = Calendar.autoupdatingCurrent.dateComponents([.day], from: startOfToday, to: completeVaccinationProtectionDate).day else {
					fatalError("Could not get days until complete protection")
				}

				vaccinationState = .fullyVaccinated(daysUntilCompleteProtection: daysUntilCompleteProtection)
			} else {
				vaccinationState = .completelyProtected
			}
		} else {
			vaccinationState = .partiallyVaccinated
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
			}
			.store(in: &subscriptions)
	}

}
