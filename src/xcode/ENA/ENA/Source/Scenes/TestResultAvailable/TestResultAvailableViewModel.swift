//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

final class TestResultAvailableViewModel {
	
	// MARK: - Init
	
	init(
		exposureSubmissionService: ExposureSubmissionService,
		didTapConsentCell: @escaping () -> Void,
		didTapPrimaryFooterButton: @escaping () -> Void,
		presentDismissAlert: @escaping () -> Void
	) {
		self.exposureSubmissionService = exposureSubmissionService
		self.didTapConsentCell = didTapConsentCell
		self.didTapPrimaryFooterButton = didTapPrimaryFooterButton
		self.presentDismissAlert = presentDismissAlert
		
		exposureSubmissionService.isSubmissionConsentGivenPublisher.sink { [weak self] consentGranted in
			guard let self = self else { return }
			self.dynamicTableViewModel = self.createDynamicTableViewModel(consentGranted)
		}.store(in: &cancellables)
	}
	
	// MARK: - Internal
	
	let didTapPrimaryFooterButton: () -> Void
	let presentDismissAlert: () -> Void

	@Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private
	
	private let exposureSubmissionService: ExposureSubmissionService
	private var cancellables: Set<AnyCancellable> = []
	private let didTapConsentCell: () -> Void
	
	private func createDynamicTableViewModel(_ consentGiven: Bool) -> DynamicTableViewModel {
		let consentStateString = consentGiven ?
			AppStrings.ExposureSubmissionTestresultAvailable.consentGranted :
			AppStrings.ExposureSubmissionTestresultAvailable.consentNotGranted

		let listItem1String = consentGiven ?
			AppStrings.ExposureSubmissionTestresultAvailable.listItem1WithConsent :
			AppStrings.ExposureSubmissionTestresultAvailable.listItem1WithoutConsent

		let listItem2String = consentGiven ?
			AppStrings.ExposureSubmissionTestresultAvailable.listItem2WithConsent :
			AppStrings.ExposureSubmissionTestresultAvailable.listItem2WithoutConsent
		
		return DynamicTableViewModel([
			// header illustatrion image with automatic height resizing
			.section(
				header: .image(
					UIImage(named: "Illu_Testresult_available"),
					accessibilityLabel: AppStrings.ExposureSubmissionTestresultAvailable.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.General.image
				),
				separators: .none,
				cells: []
			),
			// section with the sate conset
			// tap will open give consent screen
			.section(
				separators: .all,
				cells: [
					.icon(UIImage(named: "Icons_Grey_Warnen"),
						  text: .string(consentStateString),
						  action: .execute { [weak self] _, _ in
							self?.didTapConsentCell()
						  },
						  configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
						  }
					)
				]
			),
			// section with information texts
			.section(
				separators: .none,
				cells: [
					.body(text: listItem1String),
					consentGiven ? .headline(text: listItem2String) : .body(text: listItem2String)
				]
			)
		])
	}
	
}
