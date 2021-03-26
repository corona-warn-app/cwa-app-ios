//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultViewModel {
	
	// MARK: - Init
	
	init(
		testResult: TestResult,
		exposureSubmissionService: ExposureSubmissionService,
		warnOthersReminder: WarnOthersRemindable,
		onSubmissionConsentCellTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onContinueWithSymptomsFlowButtonTap: @escaping () -> Void,
		onContinueWarnOthersButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onChangeToPositiveTestResult: @escaping () -> Void,
		onTestDeleted: @escaping () -> Void
	) {
		self.testResult = testResult
		self.exposureSubmissionService = exposureSubmissionService
		self.warnOthersReminder = warnOthersReminder
		self.onSubmissionConsentCellTap = onSubmissionConsentCellTap
		self.onContinueWithSymptomsFlowButtonTap = onContinueWithSymptomsFlowButtonTap
		self.onContinueWarnOthersButtonTap = onContinueWarnOthersButtonTap
		self.onChangeToPositiveTestResult = onChangeToPositiveTestResult
		self.onTestDeleted = onTestDeleted

		updateForCurrentTestResult()
		bindToSubmissionConsent()
	}
	
	// MARK: - Internal
	
	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	@OpenCombine.Published var shouldShowDeletionConfirmationAlert: Bool = false
	@OpenCombine.Published var error: ExposureSubmissionError?
	@OpenCombine.Published var shouldAttemptToDismiss: Bool = false
	@OpenCombine.Published var footerViewModel: FooterViewModel?

	var testResult: TestResult {
		didSet {
			updateForCurrentTestResult()
		}
	}
	
	var timeStamp: Int64? {
		exposureSubmissionService.devicePairingSuccessfulTimestamp
	}
	
	func didTapPrimaryButton() {
		switch testResult {
		case .positive:
			// Determine next step based on consent state. In case the user has given exposure
			// submission consent, we continue with collecting onset of symptoms.
			// Otherwise we continue with the warn others process
			if isSubmissionConsentGiven {
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
		switch testResult {
		case .positive:
			self.shouldAttemptToDismiss = true
		case .pending:
			shouldShowDeletionConfirmationAlert = true
		case .negative, .invalid, .expired:
			break
		}
	}
	
	func deleteTest() {
		exposureSubmissionService.deleteTest()
		onTestDeleted()
		
		// Update warn others model
		self.warnOthersReminder.reset()
	}
	
	func updateWarnOthers() {
		warnOthersReminder.evaluateShowingTestResult(testResult)
	}
	
	// MARK: - Private
	
	private var exposureSubmissionService: ExposureSubmissionService
	private var warnOthersReminder: WarnOthersRemindable

	private let onSubmissionConsentCellTap: (@escaping (Bool) -> Void) -> Void
	private let onContinueWithSymptomsFlowButtonTap: () -> Void
	private let onContinueWarnOthersButtonTap: (@escaping (Bool) -> Void) -> Void

	private let onChangeToPositiveTestResult: () -> Void
	private let onTestDeleted: () -> Void

	private var isSubmissionConsentGiven: Bool = false

	private var cancellables: Set<AnyCancellable> = []
	
	
	private var primaryButtonIsLoading: Bool = false {
		didSet {
			footerViewModel?.setLoadingIndicator(primaryButtonIsLoading, disable: primaryButtonIsLoading, button: .primary)
			footerViewModel?.setLoadingIndicator(false, disable: primaryButtonIsLoading, button: .secondary)
		}
	}

	private func updateForCurrentTestResult() {
		self.dynamicTableViewModel = DynamicTableViewModel(currentTestResultSections)
		footerViewModel = ExposureSubmissionTestResultViewModel.footerViewModel(testResult: testResult, isSubmissionConsentGiven: isSubmissionConsentGiven)
	}
	
	private func refreshTest(completion: @escaping () -> Void) {
		exposureSubmissionService.getTestResult { [weak self] result in
			switch result {
			case let .failure(error):
				self?.error = error
			// Positive test results are not shown immediately
			case let .success(testResult) where testResult == .positive:
				self?.onChangeToPositiveTestResult()
			case let .success(testResult):
				self?.testResult = testResult
				self?.updateWarnOthers()
			}
			completion()
		}
	}
	
	private var currentTestResultSections: [DynamicSection] {
		switch testResult {
		case .positive:
			return isSubmissionConsentGiven ? positiveTestResultSectionsWithSubmissionConsent : positiveTestResultSectionsWithoutSubmissionConsent
		case .negative:
			return negativeTestResultSections
		case .invalid:
			return invalidTestResultSections
		case .pending:
			return pendingTestResultSections
		case .expired:
			return expiredTestResultSections
		}
	}
	
	/// This is the positive result section which will be shown, if the user
	/// has GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .positive, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentTitle),
					.headline(text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentInfo1,
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentInfo1),
					.body(text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentInfo2, accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentInfo2)
				]
			)
		]
	}
	
	/// This is the positive result section which will be shown, if the user
	/// has NOT GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithoutSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .positive, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.noConsentTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.noConsentTitle),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionPositiveTestResult.noConsentInfo1,
						description: nil,
						icon: UIImage(named: "Icons - Warnen"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .normal
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionPositiveTestResult.noConsentInfo2,
						icon: UIImage(named: "Icons - Lock"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .normal
					),
					ExposureSubmissionDynamicCell.stepCell(
						style: .body,
						title: AppStrings.ExposureSubmissionPositiveTestResult.noConsentInfo3,
						icon: UIImage(named: "Icons - Home"),
						iconTint: .enaColor(for: .riskHigh),
						hairline: .none,
						bottomSpacing: .normal
					)
				]
			)
		]
	}
	
	private var negativeTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .negative, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testAdded,
						description: nil,
						icon: UIImage(named: "Icons_Grey_Check"),
						hairline: .iconAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testNegative,
						description: AppStrings.ExposureSubmissionResult.testNegativeDesc,
						icon: UIImage(named: "Icons_Grey_Error"),
						hairline: .topAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testRemove,
						description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
						icon: UIImage(named: "Icons_Grey_Entfernen"),
						hairline: .none
					),
					
					.title2(text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.furtherInfos_Title),
					
					.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
					.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2, spacing: .large),
					.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3, spacing: .large),
					.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_TestAgain, spacing: .large)
				]
			)
		]
	}
	
	private var invalidTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .invalid, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testAdded,
						description: nil,
						icon: UIImage(named: "Icons_Grey_Check"),
						hairline: .iconAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testInvalid,
						description: AppStrings.ExposureSubmissionResult.testInvalidDesc,
						icon: UIImage(named: "Icons_Grey_Error"),
						hairline: .topAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testRemove,
						description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
						icon: UIImage(named: "Icons_Grey_Entfernen"),
						hairline: .none
					)
				]
			)
		]
	}
	
	private var pendingTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .pending, timeStamp: self.timeStamp)
					}
				),
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testAdded,
						description: nil,
						icon: UIImage(named: "Icons_Grey_Check"),
						hairline: .iconAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testPending,
						description: AppStrings.ExposureSubmissionResult.testPendingDesc,
						icon: UIImage(named: "Icons_Grey_Wait"),
						hairline: .none
					)]
			),
			.section(
				separators: .all,
				cells: [
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Grey_Warnen"),
						text: .string(
							isSubmissionConsentGiven ?
										AppStrings.ExposureSubmissionResult.warnOthersConsentGiven :
										AppStrings.ExposureSubmissionResult.warnOthersConsentNotGiven
						),
						action: .execute {[weak self] _, cell in
							guard let self = self else {
								return
							}
							self.onSubmissionConsentCellTap { [weak self] isLoading in
								let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
								activityIndicatorView.startAnimating()
								cell?.accessoryView = isLoading ? activityIndicatorView : nil
								cell?.isUserInteractionEnabled = !isLoading
								self?.footerViewModel?.setLoadingIndicator(true, disable: isLoading, button: .primary)
								self?.footerViewModel?.setLoadingIndicator(true, disable: isLoading, button: .secondary)
							}
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
							cell.accessibilityIdentifier = self.isSubmissionConsentGiven ?
								AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentGivenCell :
								AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentNotGivenCell
						}
					)
				]
			)
		]
	}
	
	private var expiredTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .invalid, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testAdded,
						description: nil,
						icon: UIImage(named: "Icons_Grey_Check"),
						hairline: .iconAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testExpired,
						description: AppStrings.ExposureSubmissionResult.testExpiredDesc,
						icon: UIImage(named: "Icons_Grey_Error"),
						hairline: .topAttached
					),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testRemove,
						description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
						icon: UIImage(named: "Icons_Grey_Entfernen"),
						hairline: .none
					)
				]
			)
		]
	}
	
	private func bindToSubmissionConsent() {
		self.exposureSubmissionService.isSubmissionConsentGivenPublisher.sink { isSubmissionConsentGiven in
			Log.info("TestResult Screen: Update content for submission consent given = \(isSubmissionConsentGiven)")
			self.isSubmissionConsentGiven = isSubmissionConsentGiven
			self.updateForCurrentTestResult()
		}.store(in: &cancellables)
	}

}

extension ExposureSubmissionTestResultViewModel {
	
	static func footerViewModel(testResult: TestResult, isSubmissionConsentGiven: Bool) -> FooterViewModel {
		switch testResult {
		case .positive:
			return FooterViewModel(
				primaryButtonName: isSubmissionConsentGiven ?
					AppStrings.ExposureSubmissionPositiveTestResult.withConsentPrimaryButtonTitle :
				 AppStrings.ExposureSubmissionPositiveTestResult.noConsentPrimaryButtonTitle,
				secondaryButtonName: isSubmissionConsentGiven ?
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
