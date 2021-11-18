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
		healthCertificateService: HealthCertificateService
	) {
		self.validationConditions = validationConditions
		self.healthCertificateService = healthCertificateService
		
//		let serviceProviderRequirementsDescription = "Impfzertifikat, Genesenenzertifikat, Schnelltest-Testzertifikat, PCR-Testzertifikat Geburtsdatum: 1989-12-12 SCHNEIDER<<ANDREA"

		self.filterCertificatesBasedOnValidationConditions()
	}
	
	// MARK: - Internal

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private
	
	private var healthCertificateService: HealthCertificateService
	private var validationConditions: ValidationConditions
	
	private func filterCertificatesBasedOnValidationConditions() {
		print(validationConditions)
		guard let certificateTypes = validationConditions.type else {
			return
		}

		var supportedCertificateTypes: [String] = []
		var suitableCertificates: [HealthCertificate] = []
		var serviceProviderRequirementsDescription: String = ""

		if let healthCertifiedPerson = self.healthCertificateService.healthCertifiedPersons.first(where: {
			$0.name?.standardizedGivenName == validationConditions.gnt &&
			$0.name?.standardizedFamilyName == validationConditions.fnt &&
			$0.dateOfBirth == validationConditions.dob
		}) {
			// if type contains v, all Vaccination Certificates shall pass the filter
			if certificateTypes.contains("v") {
				suitableCertificates.append(contentsOf: healthCertifiedPerson.vaccinationCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate)
			}
		    // if type contains r, all Recovery Certificates shall pass the filter
			if certificateTypes.contains("r") {
				suitableCertificates.append(contentsOf: healthCertifiedPerson.recoveryCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate)
			}
			// if type contains t, all Test Certificates shall pass the filter
			if certificateTypes.contains("t") {
				suitableCertificates.append(contentsOf: healthCertifiedPerson.testCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.testCertificate)
			}
			// if type contains tp, all PCR tests shall pass the filter
			if certificateTypes.contains("tp") {
				suitableCertificates.append(contentsOf: healthCertifiedPerson.pcrTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate)
			}
			// if type contains tr, all RAT tests shall pass the filter
			if certificateTypes.contains("tr") {
				suitableCertificates.append(contentsOf: healthCertifiedPerson.ratTestCertificates)
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate)
			}
			
			// sorting on the basis of certificate type
			suitableCertificates = suitableCertificates.sorted(by: >)
			
			// creating service provider requirements descriptions
			serviceProviderRequirementsDescription += supportedCertificateTypes.joined(separator: ",")
			if let dateOfBirth = validationConditions.dob {
				serviceProviderRequirementsDescription += String(format: AppStrings.TicketValidation.CertificateSelection.dateOfBirth, dateOfBirth)
			}
			if let firstName = validationConditions.fnt, let givenName = validationConditions.gnt {
				serviceProviderRequirementsDescription += "\n\(firstName)<<\(givenName)"
			}
			
			// setting up view model
			if suitableCertificates.isEmpty {
				setup(for: .noSuitableCertificate, with: serviceProviderRequirementsDescription)
			} else {
				setup(for: .suitableCertificates, with: serviceProviderRequirementsDescription)
			}
		}
	}

	private func setup(for ticketValidationCertificateSelectionState: TicketValidationCertificateSelectionState, with serviceProviderRequirementsDescription: String) {
		switch ticketValidationCertificateSelectionState {
		case .suitableCertificates:
			dynamicTableViewModel = dynamicTableViewModelSuitableCertificates(serviceProviderRequirementsDescription: serviceProviderRequirementsDescription)
		case .noSuitableCertificate:
			dynamicTableViewModel = dynamicTableViewModelNoSuitableCertificate()
	    }
	}
		
	private func dynamicTableViewModelSuitableCertificates(serviceProviderRequirementsDescription: String) -> DynamicTableViewModel {
		var suitableCertificatesCells: [DynamicCell] = [
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequirementsHeadline),
			.subheadline(
			   text: serviceProviderRequirementsDescription,
			   color: .enaColor(for: .textPrimary2)
			),
			.body(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRelevantCertificatesHeadline)
		].compactMap { $0 }

		// TODO: Logic for suitable cells

		return DynamicTableViewModel([
			.section(
				separators: .none,
				cells: suitableCertificatesCells
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
