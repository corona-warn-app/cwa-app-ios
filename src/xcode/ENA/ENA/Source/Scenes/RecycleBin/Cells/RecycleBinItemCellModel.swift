////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class RecycleBinItemCellModel {

	// MARK: - Init

	init(
		recycleBinItem: RecycleBinItem
	) {
		self.recycleBinItem = recycleBinItem
	}

	// MARK: - Internal

	lazy var iconImage: UIImage? = {
		switch recycleBinItem.item {
		case .certificate:
			return UIImage(named: "Icons_RecycleBin_Certificate")
		case .userCoronaTest:
			return UIImage(named: "Icons_RecycleBin_CoronaTest")
		case .familyMemberCoronaTest:
			return UIImage(named: "Icons_RecycleBin_FamilyMemberCoronaTest")
		}
	}()

	lazy var name: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			return certificate.name.fullName
		case .userCoronaTest:
			return nil
		case .familyMemberCoronaTest(let coronaTest):
			return coronaTest.displayName
		}
	}()

	lazy var title: String = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			switch certificate.type {
			case .vaccination:
				return AppStrings.RecycleBin.VaccinationCertificate.headline
			case .test:
				return AppStrings.RecycleBin.TestCertificate.headline
			case .recovery:
				return AppStrings.RecycleBin.RecoveryCertificate.headline
			}
		case .userCoronaTest:
			return AppStrings.RecycleBin.CoronaTest.headline
		case .familyMemberCoronaTest:
			return AppStrings.RecycleBin.CoronaTest.familyMemberHeadline
		}
	}()

	lazy var secondaryInfo: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			switch certificate.entry {
			case .vaccination(let vaccinationEntry):
				return String(
					format: AppStrings.RecycleBin.VaccinationCertificate.vaccinationCount,
					vaccinationEntry.doseNumber,
					vaccinationEntry.totalSeriesOfDoses
				)
			case .test(let testEntry) where testEntry.coronaTestType == .pcr:
				return AppStrings.RecycleBin.TestCertificate.pcrTest
			case .test(let testEntry) where testEntry.coronaTestType == .antigen:
				return AppStrings.RecycleBin.TestCertificate.antigenTest
			case .test:
				// In case the test type could not be determined
				return nil
			case .recovery:
				return nil
			}
		case .userCoronaTest(let coronaTest):
			switch coronaTest {
			case .pcr:
				return AppStrings.RecycleBin.CoronaTest.pcrTest
			case .antigen:
				return AppStrings.RecycleBin.CoronaTest.antigenTest
			}
		case .familyMemberCoronaTest(let coronaTest):
			switch coronaTest {
			case .pcr:
				return AppStrings.RecycleBin.CoronaTest.pcrTest
			case .antigen:
				return AppStrings.RecycleBin.CoronaTest.antigenTest
			}
		}
	}()

	lazy var tertiaryInfo: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			switch certificate.entry {
			case .vaccination(let vaccinationEntry):
				return vaccinationEntry.localVaccinationDate.map {
					String(
						format: AppStrings.RecycleBin.VaccinationCertificate.vaccinationDate,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			case .test(let testEntry):
				return testEntry.sampleCollectionDate.map {
					String(
						format: AppStrings.RecycleBin.TestCertificate.sampleCollectionDate,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			case .recovery(let recoveryEntry):
				return recoveryEntry.localDateOfFirstPositiveNAAResult.map {
					String(
						format: AppStrings.RecycleBin.RecoveryCertificate.positiveTestFrom,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			}
		case .userCoronaTest(let coronaTest):
			switch coronaTest {
			case .pcr(let pcrTest):
				return String(
					format: AppStrings.RecycleBin.CoronaTest.registrationDate,
					DateFormatter.localizedString(from: pcrTest.registrationDate, dateStyle: .short, timeStyle: .none)
				)
			case .antigen(let antigenTest):
				return String(
					format: AppStrings.RecycleBin.CoronaTest.sampleCollectionDate,
					DateFormatter.localizedString(from: antigenTest.testDate, dateStyle: .short, timeStyle: .none)
				)
			}
		case .familyMemberCoronaTest(let coronaTest):
			switch coronaTest {
			case .pcr(let pcrTest):
				return String(
					format: AppStrings.RecycleBin.CoronaTest.registrationDate,
					DateFormatter.localizedString(from: pcrTest.registrationDate, dateStyle: .short, timeStyle: .none)
				)
			case .antigen(let antigenTest):
				return String(
					format: AppStrings.RecycleBin.CoronaTest.sampleCollectionDate,
					DateFormatter.localizedString(from: antigenTest.testDate, dateStyle: .short, timeStyle: .none)
				)
			}
		}
	}()

	lazy var quaternaryInfo: String? = {
		guard let expirationDate = Calendar.current.date(byAdding: .day, value: RecycleBin.expirationDays, to: recycleBinItem.recycledAt) else {
			return nil
		}
		
		return String(
			format: AppStrings.RecycleBin.expirationDateTime,
			DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
			DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
		)
	}()

	// MARK: - Private

	private let recycleBinItem: RecycleBinItem
}
