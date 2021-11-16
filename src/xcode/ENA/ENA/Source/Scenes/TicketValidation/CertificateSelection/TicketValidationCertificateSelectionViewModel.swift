//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class TicketValidationCertificateSelectionViewModel {

	// MARK: - Init

	init(
		serviceProviderRequirementsDescription: String,
		ticketValidationCertificateSelectionState: TicketValidationCertificateSelectionState
	) {
		self.serviceProviderRequirementsDescription = serviceProviderRequirementsDescription
		
		self.setup(for: ticketValidationCertificateSelectionState, with: serviceProviderRequirementsDescription)
	}
	
	// MARK: - Internal

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private

	private let serviceProviderRequirementsDescription: String
	
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
