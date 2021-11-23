//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine
import HealthCertificateToolkit

class TicketValidationCertificateSelectionViewModel {

	// MARK: - Init

	init(
		validationConditions: ValidationConditions,
		healthCertificateService: HealthCertificateService,
		onHealthCertificateCellTap: @escaping(HealthCertificate, HealthCertifiedPerson) -> Void
	) {
		self.validationConditions = validationConditions
		self.healthCertificateService = healthCertificateService
		self.onHealthCertificateCellTap = onHealthCertificateCellTap
		
		self.filterCertificatesBasedOnValidationConditions()
	}
	
	// MARK: - Internal

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private
	
	private var healthCertificateService: HealthCertificateService
	private var validationConditions: ValidationConditions
	private let onHealthCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void
	
	private func filterCertificatesBasedOnValidationConditions() {
		var supportedHealthCertificates: [HealthCertificate] = []
		var supportedCertificateTypes: [String] = []

		// all certificates of all persons
		let allCertificates = self.healthCertificateService.healthCertifiedPersons.flatMap { $0.healthCertificates }
		
		// certificates that matches person's validation conditions
		let healthCertifiedPersonCertificates = allCertificates.filter({
			$0.name.standardizedGivenName == validationConditions.gnt &&
			$0.name.standardizedFamilyName == validationConditions.fnt &&
			$0.dateOfBirth == validationConditions.dob
		})
		
		if let certificateTypes = validationConditions.type, !certificateTypes.isEmpty {
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
		
		// creating service provider requirements description
		let serviceProviderRequirementsDescription = generateServiceProviderRequirementsString(supportedCertificateTypes: supportedCertificateTypes, validationConditions: validationConditions)
		
		// finding health certified person
		var healthCertifiedPerson: HealthCertifiedPerson?
		self.healthCertificateService.healthCertifiedPersons.forEach { certifiedPerson in
			supportedHealthCertificates.forEach { healthCertificate in
				if certifiedPerson.healthCertificates.contains(healthCertificate) {
					healthCertifiedPerson = certifiedPerson
				}
			}
		}
		
		// setting up view model
		if supportedHealthCertificates.isEmpty {
			dynamicTableViewModel = dynamicTableViewModelNoSupportedCertificate(serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
		} else {
			dynamicTableViewModel = dynamicTableViewModelSupportedHealthCertificates(
				healthCertifiedPerson: healthCertifiedPerson,
				supportedHealthCertificates: supportedHealthCertificates,
				serviceProviderRequirementsDescription: serviceProviderRequirementsDescription
			)
		}
	}
		
	private func generateServiceProviderRequirementsString(supportedCertificateTypes: [String], validationConditions: ValidationConditions) -> String {
		var serviceProviderRequirementsDescription: String = ""

		serviceProviderRequirementsDescription += supportedCertificateTypes.joined(separator: ", ")
		if let dateOfBirth = validationConditions.dob {
			serviceProviderRequirementsDescription += String(format: AppStrings.TicketValidation.CertificateSelection.dateOfBirth, dateOfBirth)
		}
		if let familyName = validationConditions.fnt, let givenName = validationConditions.gnt {
			serviceProviderRequirementsDescription += "\n\(familyName)<<\(givenName)"
		} else if let familyName = validationConditions.fnt {
			serviceProviderRequirementsDescription += "\n\(familyName)<<"
		} else if let givenName = validationConditions.gnt {
			serviceProviderRequirementsDescription += "\n<<\(givenName)"
		}
		
		return serviceProviderRequirementsDescription
	}

	private func dynamicTableViewModelSupportedHealthCertificates(healthCertifiedPerson: HealthCertifiedPerson?, supportedHealthCertificates: [HealthCertificate], serviceProviderRequirementsDescription: String) -> DynamicTableViewModel {
		guard let certifiedPerson = healthCertifiedPerson else {
			return DynamicTableViewModel([
				.section(
					separators: .none,
					cells: []
				)
			])
		}

		var supportedHealthCertificatesCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequirementsHeadline),
			.subheadline(
			   text: serviceProviderRequirementsDescription,
			   color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRelevantCertificatesHeadline)
		]

		for supportedHealthCertificate in supportedHealthCertificates {
			supportedHealthCertificatesCells.append(.identifier(
				TicketValidationCertificateSelectionViewController.CustomCellReuseIdentifiers.healthCertificateCell,
				action: .execute { _, _ in
					self.onHealthCertificateCellTap(supportedHealthCertificate, certifiedPerson)
				},
				configure: { _, cell, _ in
					guard let cell = cell as? HealthCertificateCell else {
						fatalError("could not initialize cell of type `HealthCertificateCell`")
					}

					cell.configure(
						HealthCertificateCellViewModel(
							healthCertificate: supportedHealthCertificate,
							healthCertifiedPerson: certifiedPerson,
							details: .overview
						)
					)
				})
			)
		}

		return DynamicTableViewModel([
			.section(
				separators: .none,
				cells: supportedHealthCertificatesCells
			)
		])
	}
		
	private func dynamicTableViewModelNoSupportedCertificate(serviceProviderRequirementsDescription: String) -> DynamicTableViewModel {
		var noSupportedCertificateCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.noSupportedCertificateHeadline),
			.subheadline(
				text: AppStrings.TicketValidation.CertificateSelection.noSupportedCertificateDescription,
				color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequiredCertificateHeadline)
		]

		noSupportedCertificateCells.append(.identifier(
			TicketValidationCertificateSelectionViewController.CustomCellReuseIdentifiers.noSupportedCertificateCell,
			configure: { _, cell, _ in
				guard let cell = cell as? TicketValidationNoSupportedCertificateCell else {
					fatalError("could not initialize cell of type `TicketValidationNoSupportedCertificateCell`")
				}

				cell.configure(
					TicketValidationNoSupportedCertificateCellModel(serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
				)
			})
		)

		noSupportedCertificateCells.append(
			.textWithLinks(
				text: String(
					format: AppStrings.TicketValidation.CertificateSelection.faqDescription,
					AppStrings.TicketValidation.CertificateSelection.faq),
				links: [
					AppStrings.TicketValidation.CertificateSelection.faq: AppStrings.Links.ticketValidationNoValidDCCFAQ
				],
				linksColor: .enaColor(for: .textTint),
				style: .footnote
			)
		)
		
		return DynamicTableViewModel([
			.section(
				separators: .none,
				cells: noSupportedCertificateCells
			)
		])
	}
}
