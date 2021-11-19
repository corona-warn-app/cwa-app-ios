//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

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
		
		self.supportedHealthCertificates = []
		self.filterCertificatesBasedOnValidationConditions()
	}
	
	// MARK: - Internal

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private
	
	private var healthCertificateService: HealthCertificateService
	private var validationConditions: ValidationConditions
	private let onHealthCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void
	private var supportedHealthCertificates: [HealthCertificate]
	
	private func filterCertificatesBasedOnValidationConditions() {
		guard let certificateTypes = validationConditions.type else {
			return
		}

		var supportedCertificateTypes: [String] = []
		var serviceProviderRequirementsDescription: String = ""

		if let healthCertifiedPerson = self.healthCertificateService.healthCertifiedPersons.first(where: {
			$0.name?.standardizedGivenName == validationConditions.gnt &&
			$0.name?.standardizedFamilyName == validationConditions.fnt &&
			$0.dateOfBirth == validationConditions.dob
		}) {
			// if type contains v, all Vaccination Certificates shall pass the filter
			if certificateTypes.contains("v") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPerson.vaccinationCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate)
			}
		    // if type contains r, all Recovery Certificates shall pass the filter
			if certificateTypes.contains("r") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPerson.recoveryCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate)
			}
			// if type contains t, all Test Certificates shall pass the filter
			if certificateTypes.contains("t") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPerson.testCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.testCertificate)
			}
			// if type contains tp, all PCR tests shall pass the filter
			if certificateTypes.contains("tp") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPerson.pcrTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate)
			}
			// if type contains tr, all RAT tests shall pass the filter
			if certificateTypes.contains("tr") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPerson.ratTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate)
			}
			
			// sorting on the basis of certificate type
			supportedHealthCertificates = supportedHealthCertificates.sorted(by: >)
			
			// creating service provider requirements descriptions
			serviceProviderRequirementsDescription += supportedCertificateTypes.joined(separator: ", ")
			if let dateOfBirth = validationConditions.dob {
				serviceProviderRequirementsDescription += String(format: AppStrings.TicketValidation.CertificateSelection.dateOfBirth, dateOfBirth)
			}
			if let firstName = validationConditions.fnt, let givenName = validationConditions.gnt {
				serviceProviderRequirementsDescription += "\n\(firstName)<<\(givenName)"
			}
			
			// setting up view model
			if supportedHealthCertificates.isEmpty {
				setup(for: .noSupportedHealthCertificate, healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
			} else {
				setup(for: .supportedHealthCertificates, healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
			}
		}
	}

	private func setup(for ticketValidationCertificateSelectionState: TicketValidationCertificateSelectionState, healthCertifiedPerson: HealthCertifiedPerson, serviceProviderRequirementsDescription: String) {
		switch ticketValidationCertificateSelectionState {
		case .supportedHealthCertificates:
			dynamicTableViewModel = dynamicTableViewModelSupportedHealthCertificates(healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
		case .noSupportedHealthCertificate:
			dynamicTableViewModel = dynamicTableViewModelNoSupportedCertificate()
	    }
	}
		
	private func dynamicTableViewModelSupportedHealthCertificates(healthCertifiedPerson: HealthCertifiedPerson, serviceProviderRequirementsDescription: String) -> DynamicTableViewModel {
		var supportedHealthCertificatesCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequirementsHeadline),
			.subheadline(
			   text: serviceProviderRequirementsDescription,
			   color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRelevantCertificatesHeadline)
		].compactMap { $0 }

		for supportedHealthCertificate in supportedHealthCertificates {
			supportedHealthCertificatesCells.append(DynamicCell.identifier(
				TicketValidationCertificateSelectionViewController.CustomCellReuseIdentifiers.healthCertificateCell,
				action: .execute { _, _ in
					self.onHealthCertificateCellTap(supportedHealthCertificate, healthCertifiedPerson)
				},
				configure: { _, cell, _ in
					guard let cell = cell as? HealthCertificateCell else {
						fatalError("could not initialize cell of type `HealthCertificateCell`")
					}

					cell.configure(
						HealthCertificateCellViewModel(
							healthCertificate: supportedHealthCertificate,
							healthCertifiedPerson: healthCertifiedPerson
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
		
	private func dynamicTableViewModelNoSupportedCertificate() -> DynamicTableViewModel {
		var noSupportedCertificateCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.noSupportedCertificateHeadline),
			.subheadline(
				text: AppStrings.TicketValidation.CertificateSelection.noSupportedCertificateDescription,
				color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequiredCertificateHeadline)
		].compactMap { $0 }

		// TODO: Logic for no suitable cell

		noSupportedCertificateCells.append(
			.textWithLinks(
				text: String(
					format: AppStrings.TicketValidation.CertificateSelection.faqDescription,
					AppStrings.TicketValidation.CertificateSelection.faq),
				links: [
					AppStrings.TicketValidation.CertificateSelection.faq: AppStrings.Links.ticketValidationFAQ
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
