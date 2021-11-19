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
		
		self.suitableHealthCertificates = []
		self.filterCertificatesBasedOnValidationConditions()
	}
	
	// MARK: - Internal

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private
	
	private var healthCertificateService: HealthCertificateService
	private var validationConditions: ValidationConditions
	private let onHealthCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void
	private var suitableHealthCertificates: [HealthCertificate]
	
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
				suitableHealthCertificates.append(contentsOf: healthCertifiedPerson.vaccinationCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate)
			}
		    // if type contains r, all Recovery Certificates shall pass the filter
			if certificateTypes.contains("r") {
				suitableHealthCertificates.append(contentsOf: healthCertifiedPerson.recoveryCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate)
			}
			// if type contains t, all Test Certificates shall pass the filter
			if certificateTypes.contains("t") {
				suitableHealthCertificates.append(contentsOf: healthCertifiedPerson.testCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.testCertificate)
			}
			// if type contains tp, all PCR tests shall pass the filter
			if certificateTypes.contains("tp") {
				suitableHealthCertificates.append(contentsOf: healthCertifiedPerson.pcrTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate)
			}
			// if type contains tr, all RAT tests shall pass the filter
			if certificateTypes.contains("tr") {
				suitableHealthCertificates.append(contentsOf: healthCertifiedPerson.ratTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate)
			}
			
			// sorting on the basis of certificate type
			suitableHealthCertificates = suitableHealthCertificates.sorted(by: >)
			
			// creating service provider requirements descriptions
			serviceProviderRequirementsDescription += supportedCertificateTypes.joined(separator: ", ")
			if let dateOfBirth = validationConditions.dob {
				serviceProviderRequirementsDescription += String(format: AppStrings.TicketValidation.CertificateSelection.dateOfBirth, dateOfBirth)
			}
			if let firstName = validationConditions.fnt, let givenName = validationConditions.gnt {
				serviceProviderRequirementsDescription += "\n\(firstName)<<\(givenName)"
			}
			
			// setting up view model
			if suitableHealthCertificates.isEmpty {
				setup(for: .noSuitableHealthCertificate, healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
			} else {
				setup(for: .suitableHealthCertificates, healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
			}
		}
	}

	private func setup(for ticketValidationCertificateSelectionState: TicketValidationCertificateSelectionState, healthCertifiedPerson: HealthCertifiedPerson, serviceProviderRequirementsDescription: String) {
		switch ticketValidationCertificateSelectionState {
		case .suitableHealthCertificates:
			dynamicTableViewModel = dynamicTableViewModelsuitableHealthCertificates(healthCertifiedPerson: healthCertifiedPerson, serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
		case .noSuitableHealthCertificate:
			dynamicTableViewModel = dynamicTableViewModelNoSuitableCertificate()
	    }
	}
		
	private func dynamicTableViewModelsuitableHealthCertificates(healthCertifiedPerson: HealthCertifiedPerson, serviceProviderRequirementsDescription: String) -> DynamicTableViewModel {
		var suitableHealthCertificatesCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequirementsHeadline),
			.subheadline(
			   text: serviceProviderRequirementsDescription,
			   color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRelevantCertificatesHeadline)
		].compactMap { $0 }

		for suitableHealthCertificate in suitableHealthCertificates {
			suitableHealthCertificatesCells.append(DynamicCell.identifier(
				TicketValidationCertificateSelectionViewController.CustomCellReuseIdentifiers.healthCertificateCell,
				action: .execute { _, _ in
					self.onHealthCertificateCellTap(suitableHealthCertificate, healthCertifiedPerson)
				},
				configure: { _, cell, _ in
					guard let cell = cell as? HealthCertificateCell else {
						fatalError("could not initialize cell of type `HealthCertificateCell`")
					}

					cell.configure(
						HealthCertificateCellViewModel(
							healthCertificate: suitableHealthCertificate,
							healthCertifiedPerson: healthCertifiedPerson
						)
					)
				})
			)
		}

		return DynamicTableViewModel([
			.section(
				separators: .none,
				cells: suitableHealthCertificatesCells
			)
		])
	}
		
	private func dynamicTableViewModelNoSuitableCertificate() -> DynamicTableViewModel {
		var noSuitableCertificateCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.noSuitableCertificateHeadline),
			.subheadline(
				text: AppStrings.TicketValidation.CertificateSelection.noSuitableCertificateDescription,
				color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequiredCertificateHeadline)
		].compactMap { $0 }

		// TODO: Logic for no suitable cell

		noSuitableCertificateCells.append(
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
				cells: noSuitableCertificateCells
			)
		])
	}
}
