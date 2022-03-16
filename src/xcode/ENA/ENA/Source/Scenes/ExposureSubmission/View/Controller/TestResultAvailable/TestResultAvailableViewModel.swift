//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class TestResultAvailableViewModel {
	
	// MARK: - Init
	
	init(
		coronaTestType: CoronaTestType,
		coronaTestService: CoronaTestServiceProviding,
		onSubmissionConsentCellTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onSubmissionConsentCellTap = onSubmissionConsentCellTap
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss

		switch coronaTestType {
		case .pcr:
			coronaTestService.pcrTest
				.sink { [weak self] pcrTest in
					guard let self = self, let pcrTest = pcrTest else {
						return
					}
					self.dynamicTableViewModel = self.createDynamicTableViewModel(pcrTest.isSubmissionConsentGiven)
				}
				.store(in: &cancellables)
		case .antigen:
			coronaTestService.antigenTest
				.sink { [weak self] antigenTest in
					guard let self = self, let antigenTest = antigenTest else {
						return
					}
					self.dynamicTableViewModel = self.createDynamicTableViewModel(antigenTest.isSubmissionConsentGiven)
				}
				.store(in: &cancellables)
		}
	}
	
	// MARK: - Internal
	
	let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void
	let onDismiss: () -> Void

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	@OpenCombine.Published var isLoading: Bool = false
	
	// MARK: - Private
	
	private var cancellables: Set<AnyCancellable> = []
	private let onSubmissionConsentCellTap: (@escaping (Bool) -> Void) -> Void
	
	private func createDynamicTableViewModel(_ consentGiven: Bool) -> DynamicTableViewModel {
		let consentStateString = consentGiven ?
			AppStrings.ExposureSubmissionTestResultAvailable.consentGranted :
			AppStrings.ExposureSubmissionTestResultAvailable.consentNotGranted

		let listItem1String = consentGiven ?
			AppStrings.ExposureSubmissionTestResultAvailable.listItem1WithConsent :
			AppStrings.ExposureSubmissionTestResultAvailable.listItem1WithoutConsent

		let listItem2String = consentGiven ?
			AppStrings.ExposureSubmissionTestResultAvailable.listItem2WithConsent :
			AppStrings.ExposureSubmissionTestResultAvailable.listItem2WithoutConsent
		
		return DynamicTableViewModel([
			// header illustration image with automatic height resizing
			.section(
				header: .image(
					UIImage(named: "Illu_Testresult_available"),
					accessibilityLabel: AppStrings.ExposureSubmissionTestResultAvailable.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.General.image
				),
				separators: .none,
				cells: []
			),
			// section with the consent state
			.section(
				separators: .all,
				cells: [
					.icon(
						UIImage(named: "Icons_Grey_Warnen"),
						text: .string(consentStateString),
						action: .execute { [weak self] _, cell in
							guard let self = self else { return }

							self.onSubmissionConsentCellTap { [weak self] isLoading in
								self?.isLoading = isLoading
								let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
								activityIndicatorView.startAnimating()
								cell?.accessoryView = isLoading ? activityIndicatorView : nil
								cell?.isUserInteractionEnabled = !isLoading
							}
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
