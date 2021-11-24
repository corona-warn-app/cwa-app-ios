//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension ValidationConditions {
	static let pcrTypeString = "LP6464-4"
	static let antigenTypeString = "LP217198-3"

	func filterCertificates(healthCertifiedPersons: [HealthCertifiedPerson]) -> (supportedHealthCertificates: [HealthCertificate], supportedCertificateTypes: [String]) {
		var supportedHealthCertificates: [HealthCertificate] = []
		var supportedCertificateTypes: [String] = []

		// all certificates of all persons
		let allCertificates = healthCertifiedPersons.flatMap { $0.healthCertificates }
		
		// certificates that matches person's validation conditions
		let healthCertifiedPersonCertificates = allCertificates.filter({
			$0.name.standardizedGivenName == self.gnt &&
			$0.name.standardizedFamilyName == self.fnt &&
			$0.dateOfBirth == self.dob
		})
		
		if let certificateTypes = self.type, !certificateTypes.isEmpty {
			// if type contains v, all Vaccination Certificates shall pass the filter
			if certificateTypes.contains("v") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.vaccinationEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate)
			}
			// if type contains r, all Recovery Certificates shall pass the filter
			if certificateTypes.contains("r") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.recoveryEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate)
			}
			// if type contains t, all Test Certificates shall pass the filter
			if certificateTypes.contains("t") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.testCertificate)
			}
			// if type contains tp, all PCR tests shall pass the filter
			if certificateTypes.contains("tp") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil && $0.testEntry?.typeOfTest == TestEntry.pcrTypeString })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate)
			}
			// if type contains tr, all RAT tests shall pass the filter
			if certificateTypes.contains("tr") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil && $0.testEntry?.typeOfTest == TestEntry.antigenTypeString })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate)
			}
		} else {
			// if type is nil or empty, then there is no filtering by type
			supportedHealthCertificates = healthCertifiedPersonCertificates
		}
		
		// sorting on the basis of certificate type
		supportedHealthCertificates = supportedHealthCertificates.sorted(by: >)
		
		return (supportedHealthCertificates, supportedCertificateTypes)
	}
	
	func serviceProviderRequirementsString(supportedCertificateTypes: [String]) -> String {
		var serviceProviderRequirementsDescription: String = ""
		
		// supported certificate types separated by comma
		serviceProviderRequirementsDescription += supportedCertificateTypes.joined(separator: ", ")
		// based on dob without any additional formating
		if let dateOfBirth = self.dob {
			serviceProviderRequirementsDescription += String(format: AppStrings.TicketValidation.CertificateSelection.dateOfBirth, dateOfBirth)
		}
		// concatenation of fnt and gnt separated by <<. If one of them is empty, an empty string shall be used.
		if let familyName = self.fnt, let givenName = self.gnt {
			serviceProviderRequirementsDescription += "\n\(familyName)<<\(givenName)"
		} else if let familyName = self.fnt {
			serviceProviderRequirementsDescription += "\n\(familyName)<<"
		} else if let givenName = self.gnt {
			serviceProviderRequirementsDescription += "\n<<\(givenName)"
		}
		
		return serviceProviderRequirementsDescription
	}
}
