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
		case .coronaTest:
			return UIImage(named: "Icons_RecycleBin_CoronaTest")
		}
	}()

	lazy var name: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			return certificate.name.fullName
		case .coronaTest:
			return nil
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
		case .coronaTest(let coronaTest):
			return AppStrings.RecycleBin.CoronaTest.headline
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
		case .coronaTest(let coronaTest):
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
				return recoveryEntry.localCertificateValidityEndDate.map {
					String(
						format: AppStrings.RecycleBin.RecoveryCertificate.validityDate,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			}
		case .coronaTest(let coronaTest):
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

	// MARK: - Private

	private let recycleBinItem: RecycleBinItem
    
}
