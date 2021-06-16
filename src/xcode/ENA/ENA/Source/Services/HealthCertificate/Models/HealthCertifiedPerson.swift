////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPerson: Codable, Equatable {

	// MARK: - Init

	init(
		healthCertificates: [HealthCertificate],
		isPreferredPerson: Bool = false
	) {
		self.healthCertificates = healthCertificates
		self.isPreferredPerson = isPreferredPerson

		updateVaccinationState()
		subscribeToNotifications()
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

		updateVaccinationState()
		subscribeToNotifications()
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

	// MARK: - Internal

	enum VaccinationState: Equatable {
		case partiallyVaccinated
		case fullyVaccinated(daysUntilCompleteProtection: Int)
		case completelyProtected(expirationDate: Date)

		var gradientType: GradientView.GradientType {
			switch self {
			case .partiallyVaccinated:
				return .solidGrey
			case .fullyVaccinated:
				return .solidGrey
			case .completelyProtected:
				return .lightBlue
			}
		}
	}

	var healthCertificates: [HealthCertificate] {
		didSet {
			updateVaccinationState()

			if healthCertificates != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var isPreferredPerson: Bool {
		didSet {
			if isPreferredPerson != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@OpenCombine.Published var vaccinationState: VaccinationState = .partiallyVaccinated {
		didSet {
			if vaccinationState != oldValue {
				objectDidChange.send(self)
			}
		}
	}

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

	var mostRelevantHealthCertificate: HealthCertificate? {
		let sortedHealthCertificates = healthCertificates.sorted()
		let pcrTestType = "LP6464-4"
		let antigenTestType = "LP217198-3"

		// PCR Test Certificate < 48 hours

		let currentPCRTest = sortedHealthCertificates
			.last {
				guard let typeOfTest = $0.testEntry?.typeOfTest, let ageInHours = $0.ageInHours else {
					return false
				}

				return typeOfTest == pcrTestType && ageInHours < 48
			}

		if let currentPCRTest = currentPCRTest {
			return currentPCRTest
		}

		// RAT Test Certificate < 24 hours

		let currentAntigenTest = sortedHealthCertificates
			.last {
				guard let typeOfTest = $0.testEntry?.typeOfTest, let ageInHours = $0.ageInHours else {
					return false
				}

				return typeOfTest == antigenTestType && ageInHours < 24
			}

		if let currentAntigenTest = currentAntigenTest {
			return currentAntigenTest
		}

		// Series-completing Vaccination Certificate > 14 days

		let protectingVaccinationCertificate = sortedHealthCertificates
			.last {
				guard let isLastDoseInASeries = $0.vaccinationEntry?.isLastDoseInASeries, let ageInDays = $0.ageInDays else {
					return false
				}

				return isLastDoseInASeries && ageInDays > 14
			}

		if let protectingVaccinationCertificate = protectingVaccinationCertificate {
			return protectingVaccinationCertificate
		}

		// Recovery Certificate <= 180 days

		let validRecoveryCertificate = sortedHealthCertificates
			.last {
				guard let ageInDays = $0.ageInDays else {
					return false
				}

				return $0.type == .recovery && ageInDays <= 180
			}

		if let validRecoveryCertificate = validRecoveryCertificate {
			return validRecoveryCertificate
		}

		// Series-completing Vaccination Certificate <= 14 days

		let seriesCompletingVaccinationCertificate = sortedHealthCertificates
			.last {
				guard let isLastDoseInASeries = $0.vaccinationEntry?.isLastDoseInASeries, let ageInDays = $0.ageInDays else {
					return false
				}

				return isLastDoseInASeries && ageInDays <= 14
			}

		if let seriesCompletingVaccinationCertificate = seriesCompletingVaccinationCertificate {
			return seriesCompletingVaccinationCertificate
		}

		// Other Vaccination Certificate

		if let otherVaccinationCertificate = sortedHealthCertificates.last(where: { $0.type == .vaccination }) {
			return otherVaccinationCertificate
		}

		// Recovery Certificate > 180 days

		if let otherRecoveryCertificate = sortedHealthCertificates.last(where: { $0.type == .recovery }) {
			return otherRecoveryCertificate
		}

		// PCR Test Certificate > 48 hours

		if let otherPCRTestCertificate = sortedHealthCertificates.last(where: { $0.testEntry?.typeOfTest == pcrTestType }) {
			return otherPCRTestCertificate
		}

		// RAT Test Certificate > 24 hours

		if let otherAntigenTestCertificate = sortedHealthCertificates.last(where: { $0.testEntry?.typeOfTest == antigenTestType }) {
			return otherAntigenTestCertificate
		}

		// Fallback

		return healthCertificates.first
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private var completeVaccinationProtectionDate: Date? {
		guard
			let lastVaccination = vaccinationCertificates.filter({ $0.vaccinationEntry?.isLastDoseInASeries ?? false }).max(),
			let vaccinationDateString = lastVaccination.vaccinationEntry?.dateOfVaccination,
			let vaccinationDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: vaccinationDateString)
		else {
			return nil
		}

		return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 14, to: vaccinationDate)
	}

	private var vaccinationExpirationDate: Date? {
		guard let lastVaccination = vaccinationCertificates.last(where: { $0.vaccinationEntry?.isLastDoseInASeries ?? false }) else {
			return nil
		}

		return lastVaccination.expirationDate
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
