//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
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
		
		self.setup(healthCertifiedPersons: self.healthCertificateService.healthCertifiedPersons)
	}
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	var isSupportedCertificatesEmpty: Bool = true
	
	// MARK: - Private
	
	private var healthCertificateService: HealthCertificateService
	private var validationConditions: ValidationConditions
	private let onHealthCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void
	
	private func setup(healthCertifiedPersons: [HealthCertifiedPerson]) {
		// filter certificates based on validation conditions
		let supportedCertificateTuple = validationConditions.filterCertificates(healthCertifiedPersons: healthCertifiedPersons)
		
		// creating service provider requirements description
		let serviceProviderRequirementsDescription = generateServiceProviderRequirementsString(supportedCertificateTypes: supportedCertificateTuple.supportedCertificateTypes, validationConditions: validationConditions)
		
		// finding health certified person
		let healthCertifiedPerson = healthCertifiedPersonForSupportedCertificates(healthCertifiedPersons: healthCertifiedPersons, supportedHealthCertificates: supportedCertificateTuple.supportedHealthCertificates)
		
		// setting up view model
		if supportedCertificateTuple.supportedHealthCertificates.isEmpty {
			isSupportedCertificatesEmpty = true
			dynamicTableViewModel = dynamicTableViewModelNoSupportedCertificate(serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
		} else {
			isSupportedCertificatesEmpty = false
			dynamicTableViewModel = dynamicTableViewModelSupportedHealthCertificates(
				healthCertifiedPerson: healthCertifiedPerson,
				supportedHealthCertificates: supportedCertificateTuple.supportedHealthCertificates,
				serviceProviderRequirementsDescription: serviceProviderRequirementsDescription
			)
		}
	}
		
	private func healthCertifiedPersonForSupportedCertificates(healthCertifiedPersons: [HealthCertifiedPerson], supportedHealthCertificates: [HealthCertificate]) -> HealthCertifiedPerson? {
		var healthCertifiedPerson: HealthCertifiedPerson?
		healthCertifiedPersons.forEach { certifiedPerson in
			supportedHealthCertificates.forEach { healthCertificate in
				if certifiedPerson.healthCertificates.contains(healthCertificate) {
					healthCertifiedPerson = certifiedPerson
				}
			}
		}

		return healthCertifiedPerson
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
