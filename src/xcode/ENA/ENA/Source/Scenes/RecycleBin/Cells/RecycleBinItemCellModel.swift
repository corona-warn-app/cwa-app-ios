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

	lazy var secondaryInfo: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			switch certificate.type {
			case .vaccination:
				return AppStrings.HealthCertificate.Person.VaccinationCertificate.headline
			case .test:
				return AppStrings.HealthCertificate.Person.TestCertificate.headline
			case .recovery:
				return AppStrings.HealthCertificate.Person.RecoveryCertificate.headline
			}
		case .coronaTest(let coronaTest):
			return "Test (localize!)"
		}
	}()

	lazy var tertiaryInfo: String? = {
		switch recycleBinItem.item {
		case .certificate(let certificate):
			switch certificate.entry {
			case .vaccination(let vaccinationEntry):
				return String(
					format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationCount,
					vaccinationEntry.doseNumber,
					vaccinationEntry.totalSeriesOfDoses
				)
			case .test(let testEntry) where testEntry.coronaTestType == .pcr:
				return AppStrings.HealthCertificate.Person.TestCertificate.pcrTest
			case .test(let testEntry) where testEntry.coronaTestType == .antigen:
				return AppStrings.HealthCertificate.Person.TestCertificate.antigenTest
			case .test:
				// In case the test type could not be determined
				return nil
			case .recovery:
				return nil
			}
		case .coronaTest(let coronaTest):
			return "Test (localize!)"
		}

	}()

	// MARK: - Private

	private let recycleBinItem: RecycleBinItem
    
}
