//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultViewModel {
	
	// MARK: - Init
	
	init(
		coronaTestType: CoronaTestType,
		coronaTestService: CoronaTestService,
		onSubmissionConsentCellTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onContinueWithSymptomsFlowButtonTap: @escaping () -> Void,
		onContinueWarnOthersButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onChangeToPositiveTestResult: @escaping () -> Void,
		onTestDeleted: @escaping () -> Void
	) {
		self.coronaTestType = coronaTestType
		self.coronaTestService = coronaTestService
		self.onSubmissionConsentCellTap = onSubmissionConsentCellTap
		self.onContinueWithSymptomsFlowButtonTap = onContinueWithSymptomsFlowButtonTap
		self.onContinueWarnOthersButtonTap = onContinueWarnOthersButtonTap
		self.onChangeToPositiveTestResult = onChangeToPositiveTestResult
		self.onTestDeleted = onTestDeleted

		guard let coronaTest = coronaTestService.coronaTest(ofType: coronaTestType) else {
			onTestDeleted()
			return
		}

		self.coronaTest = coronaTest
		bindToCoronaTestUpdates()
	}
	
	// MARK: - Internal
	
	let onSubmissionConsentCellTap: (@escaping (Bool) -> Void) -> Void
	
	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	@OpenCombine.Published var shouldShowDeletionConfirmationAlert: Bool = false
	@OpenCombine.Published var error: CoronaTestServiceError?
	@OpenCombine.Published var shouldAttemptToDismiss: Bool = false
	@OpenCombine.Published var footerViewModel: FooterViewModel?
	
	var coronaTest: CoronaTest!
	
	var timeStamp: Int64? {
		coronaTestService.coronaTest(ofType: coronaTestType).map { Int64($0.testDate.timeIntervalSince1970) }
	}
	
	var title: String {
		switch coronaTest.type {
		case .pcr:
			return AppStrings.ExposureSubmissionResult.PCR.title
		case .antigen:
			return AppStrings.ExposureSubmissionResult.Antigen.title
		}
	}
	
	func didTapPrimaryButton() {
		switch coronaTest.testResult {
		case .positive:
			// Determine next step based on consent state. In case the user has given exposure
			// submission consent, we continue with collecting onset of symptoms.
			// Otherwise we continue with the warn others process
			if coronaTest.isSubmissionConsentGiven {
				Log.info("Positive Test Result: Next -> 'onset of symptoms'.")
				onContinueWithSymptomsFlowButtonTap()
			} else {
				Log.info("Positive Test Result: Next -> 'warn others'.")
				onContinueWarnOthersButtonTap { [weak self] isLoading in
					self?.primaryButtonIsLoading = isLoading
				}
			}
			
		case .negative, .invalid, .expired:
			shouldShowDeletionConfirmationAlert = true
		case .pending:
			primaryButtonIsLoading = true
			
			refreshTest { [weak self] in
				self?.primaryButtonIsLoading = false
			}
		}
	}
	
	func didTapSecondaryButton() {
		switch coronaTest.testResult {
		case .positive:
			self.shouldAttemptToDismiss = true
		case .pending:
			shouldShowDeletionConfirmationAlert = true
		case .negative, .invalid, .expired:
			break
		}
	}
	
	func deleteTest() {
		coronaTestService.removeTest(coronaTestType)
		onTestDeleted()
	}
	
	func updateWarnOthers() {
		coronaTestService.evaluateShowingTest(ofType: coronaTestType)
	}
	
	// MARK: - Private
	
	private var coronaTestService: CoronaTestService

	private let coronaTestType: CoronaTestType

	private let onContinueWithSymptomsFlowButtonTap: () -> Void
	private let onContinueWarnOthersButtonTap: (@escaping (Bool) -> Void) -> Void

	private let onChangeToPositiveTestResult: () -> Void
	private let onTestDeleted: () -> Void

	private var subscriptions = Set<AnyCancellable>()
	
	private var primaryButtonIsLoading: Bool = false {
		didSet {
			footerViewModel?.setLoadingIndicator(primaryButtonIsLoading, disable: primaryButtonIsLoading, button: .primary)
			footerViewModel?.setLoadingIndicator(false, disable: primaryButtonIsLoading, button: .secondary)
		}
	}

	private func bindToCoronaTestUpdates() {
		switch coronaTestType {
		case .pcr:
			coronaTestService.$pcrTest
				.sink { [weak self] pcrTest in
					guard let pcrTest = pcrTest else {
						return
					}

					self?.updateForCurrentTestResult(coronaTest: .pcr(pcrTest))
				}
				.store(in: &subscriptions)
		case .antigen:
			coronaTestService.$antigenTest
				.sink { [weak self] antigenTest in
					guard let antigenTest = antigenTest else {
						return
					}

					self?.updateForCurrentTestResult(coronaTest: .antigen(antigenTest))
				}
				.store(in: &subscriptions)
		}
	}

	private func updateForCurrentTestResult(coronaTest: CoronaTest) {
		// Positive test results are not shown immediately
		if coronaTest.testResult == .positive && self.coronaTest.testResult != .positive {
			self.onChangeToPositiveTestResult()
		}

		self.coronaTest = coronaTest

		switch coronaTest.type {
		case .pcr:
			dynamicTableViewModel = pcrTableViewModel()
		case .antigen:
			dynamicTableViewModel = antigenTableViewModel()
		}
		
		footerViewModel = ExposureSubmissionTestResultViewModel.footerViewModel(coronaTest: coronaTest)
	}
	
	private func refreshTest(completion: @escaping () -> Void) {
		coronaTestService.updateTestResult(for: coronaTestType) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case let .failure(error):
				self.error = error
			case .success:
				break
			}

			completion()
		}
	}
}

extension ExposureSubmissionTestResultViewModel {
	
	static func footerViewModel(coronaTest: CoronaTest) -> FooterViewModel {
		switch coronaTest.testResult {
		case .positive:
			return FooterViewModel(
				primaryButtonName: coronaTest.isSubmissionConsentGiven ?
					AppStrings.ExposureSubmissionPositiveTestResult.withConsentPrimaryButtonTitle :
				 AppStrings.ExposureSubmissionPositiveTestResult.noConsentPrimaryButtonTitle,
				secondaryButtonName: coronaTest.isSubmissionConsentGiven ?
					AppStrings.ExposureSubmissionPositiveTestResult.withConsentSecondaryButtonTitle :
					AppStrings.ExposureSubmissionPositiveTestResult.noConsentSecondaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				isSecondaryButtonEnabled: true,
				isSecondaryButtonHidden: false
			)
		case .negative, .invalid, .expired:
			return FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionResult.deleteButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		case .pending:
			return FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionResult.refreshButton,
				secondaryButtonName: AppStrings.ExposureSubmissionResult.deleteButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				secondaryButtonInverted: true
			)
		}
	}
}
