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
	
	var title: String {
		if showSpecialCaseForNegativeAntigenTest {
			return AppStrings.ExposureSubmissionResult.Antigen.title
		} else {
			return AppStrings.ExposureSubmissionResult.PCR.title
		}
	}
	
	func didTapPrimaryButton() {
		switch coronaTest.testResult {
		case .positive:
			// Determine next step based on consent and submission state.
			// If the keys were submitted, the test is supposed to be deleted and the alert is shown.
			// If the keys were not yet submitted, the following scenarios can occur:
			// In case the user has given exposure submission consent, we continue with collecting onset of symptoms.
			// Otherwise we continue with the warn others process.
			if coronaTest.keysSubmitted {
				shouldShowDeletionConfirmationAlert = true
			} else if coronaTest.isSubmissionConsentGiven {
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
			refreshTest()
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
	
	func updateTestResultIfPossible() {
		guard coronaTest.testResult == .pending else {
			Log.info("Not refreshing test because status is pending")
			return
		}
		refreshTest()
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
	
	private var showSpecialCaseForNegativeAntigenTest: Bool {
		return coronaTest.type == .antigen && coronaTest.testResult == .negative
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

		let sections: [DynamicSection]
		switch coronaTest.testResult {
		case .positive where coronaTest.keysSubmitted:
			sections = positiveTestResultWithSubmittedKeys
		case .positive:
			sections = coronaTest.isSubmissionConsentGiven ? positiveTestResultSectionsWithSubmissionConsent : positiveTestResultSectionsWithoutSubmissionConsent
		case .negative:
			if let test = coronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
				sections = negativeAntigenTestResultSections(test: test)
			} else {
				sections = negativeTestResultSections
			}
		case .invalid:
			sections = invalidTestResultSections
		case .pending:
			sections = pendingTestResultSections
		case .expired:
			sections = expiredTestResultSections
		}
		dynamicTableViewModel = DynamicTableViewModel(sections)
		
		footerViewModel = ExposureSubmissionTestResultViewModel.footerViewModel(coronaTest: coronaTest)
	}
	
	private func refreshTest() {
		Log.info("Refresh test.")

		primaryButtonIsLoading = true
		coronaTestService.updateTestResult(for: coronaTestType) { [weak self] result in
			guard let self = self else { return }
			
			self.primaryButtonIsLoading = false
			
			switch result {
			case let .failure(error):
				self.error = error
			case .success:
				break
			}
		}
	}
}

// MARK: - Pending
extension ExposureSubmissionTestResultViewModel {
	
	private var pendingTestResultSections: [DynamicSection] {
		
		var cells = [DynamicCell.title2(
						text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
		)]
		
		switch coronaTest.type {
		case .pcr:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testPending,
					description: AppStrings.ExposureSubmissionResult.PCR.testPendingDesc,
					icon: UIImage(named: "Icons_Grey_Wait"),
					hairline: .iconAttached
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testPendingContactJournal,
					description: AppStrings.ExposureSubmissionResult.PCR.testPendingContactJournalDesc,
					icon: UIImage(named: "test-result-diary_light"),
					hairline: .iconAttached
				)
			])
			if let test = coronaTest.pcrTest {
				if !test.certificateConsentGiven {
					cells.append(
						ExposureSubmissionDynamicCell.stepCell(
							title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
							description: AppStrings.ExposureSubmissionResult.testCertificateNotRequested,
							icon: UIImage(named: "certificate-qr-light"),
							hairline: .none
						)
					)
				} else if !test.certificateRequested {
					cells.append(
						ExposureSubmissionDynamicCell.stepCell(
							title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
							description: AppStrings.ExposureSubmissionResult.testCertificatePending,
							icon: UIImage(named: "certificate-qr-light"),
							hairline: .none
						)
					)
				}
			}
		case .antigen:
				cells.append(contentsOf: [
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.Antigen.testAdded,
						description: nil,
						icon: UIImage(named: "Icons_Grey_Check"),
						hairline: .iconAttached
					),
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.Antigen.testPending,
						description: AppStrings.ExposureSubmissionResult.Antigen.testPendingDesc,
						icon: UIImage(named: "Icons_Grey_Wait"),
						hairline: .iconAttached
					),
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.PCR.testPendingContactJournal,
						description: AppStrings.ExposureSubmissionResult.PCR.testPendingContactJournalDesc,
						icon: UIImage(named: "test-result-diary_light"),
						hairline: .iconAttached
					)
				])
			
			if let test = coronaTest.antigenTest {
				if !test.certificateSupportedByPointOfCare {
					cells.append(
						ExposureSubmissionDynamicCell.stepCell(
							title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
							description: AppStrings.ExposureSubmissionResult.Antigen.testCenterNotSupportedTitle,
							icon: UIImage(named: "certificate-qr-light"),
							hairline: .none
						)
					)
				} else if !test.certificateConsentGiven {
					cells.append(
						ExposureSubmissionDynamicCell.stepCell(
							title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
							description: AppStrings.ExposureSubmissionResult.testCertificateNotRequested,
							icon: UIImage(named: "certificate-qr-light"),
							hairline: .none
						)
					)
				} else if !test.certificateRequested {
					cells.append(
						ExposureSubmissionDynamicCell.stepCell(
							title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
							description: AppStrings.ExposureSubmissionResult.testCertificatePending,
							icon: UIImage(named: "certificate-qr-light"),
							hairline: .none
						)
					)
				}
			}
		}
		
		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				cells: cells
			),
			.section(
				separators: .all,
				cells: [
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Grey_Warnen"),
						text: .string(
							coronaTest.isSubmissionConsentGiven ?
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
								self?.footerViewModel?.setEnabled(!isLoading, button: .primary)
								self?.footerViewModel?.setEnabled(!isLoading, button: .secondary)
							}
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
							cell.accessibilityIdentifier = self.coronaTest.isSubmissionConsentGiven ?
								AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentGivenCell :
								AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentNotGivenCell
						}
					)
				]
			)
		]
	}
}

// MARK: - Positiv
extension ExposureSubmissionTestResultViewModel {
	
	/// This is the positive result section which will be shown, if the user
	/// has NOT GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithoutSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				separators: .none,
				cells: [
					.title2(
						text: AppStrings.ExposureSubmissionPositiveTestResult.noConsentTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.noConsentTitle
					),
					
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
	
	/// This is the positive result section which will be shown, if the user
	/// has GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				separators: .none,
				cells: [
					.title2(
						text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentTitle
					),
					.headline(
						text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentInfo1,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentInfo1
					),
					.body(
						text: AppStrings.ExposureSubmissionPositiveTestResult.withConsentInfo2,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionPositiveTestResult.withConsentInfo2
					)
				]
			)
		]
	}

	/// This is the positive result section which will be shown, if the user
	/// has NOT GIVEN submission consent to share the positive test result with others
	private var positiveTestResultWithSubmittedKeys: [DynamicSection] {
		var cells: [DynamicCell] = [
			.body(text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedDescription),
			.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedTitle1)
		]

		if coronaTest.type == .antigen {
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedInfo1,
					icon: UIImage(named: "Icons - Test Tube"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				)
			)
		}

		cells.append(contentsOf: [
			ExposureSubmissionDynamicCell.stepCell(
				style: .body,
				title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedInfo2,
				icon: UIImage(named: "Icons - Hotline"),
				iconTint: .enaColor(for: .riskHigh),
				hairline: .none,
				bottomSpacing: .medium
			),
			ExposureSubmissionDynamicCell.stepCell(
				style: .body,
				title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedInfo3,
				icon: UIImage(named: "Icons - Home"),
				iconTint: .enaColor(for: .riskHigh),
				hairline: .none,
				bottomSpacing: .medium
			),
			.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedTitle2),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo1,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo2,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo3,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo4,
				spacing: .large
			)
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}

// MARK: - Negative
extension ExposureSubmissionTestResultViewModel {
	
	private var negativeTestResultSections: [DynamicSection] {
		
		let header: DynamicHeader
		
		if let test = coronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
			header = .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.antigenTestResult,
				configure: { view, _ in
					(view as? AntigenExposureSubmissionNegativeTestResultHeaderView)?.configure(coronaTest: test)
				}
			)
		} else {
			header = .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
				}
			)
		}
		
		var cells = [DynamicCell.title2(
			text: AppStrings.ExposureSubmissionResult.procedure,
			accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
		)]
		
		switch coronaTest.type {
		case .pcr:
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			)
			
		case .antigen:
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			)
		}
		
		cells.append(contentsOf: [
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
				hairline: coronaTest.certificateRequested ? .iconAttached : .none
			)
			
		])

		if coronaTest.certificateRequested {
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
					description: AppStrings.ExposureSubmissionResult.testCertificateAvailableInTheTab,
					icon: UIImage(named: "certificate-qr-light"),
					hairline: .none
				)
			)
		}

		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.furtherInfos_Title
			),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_TestAgain, spacing: .large)
		])
		
		return [
			.section(
				header: header,
				separators: .none,
				cells: cells
			)
		]
	}
	
	private func negativeAntigenTestResultSections(test: AntigenTest) -> [DynamicSection] {
		var cells = [DynamicCell]()

		if test.testedPerson.fullName != nil && test.testedPerson.dateOfBirth != nil {
			cells.append(contentsOf: [
				.title2(
					text: AppStrings.ExposureSubmissionResult.Antigen.proofTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofTitle
				),
				.body(
					text: AppStrings.ExposureSubmissionResult.Antigen.proofDesc,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofDesc
				)
			])
		} else {
			cells.append(contentsOf: [
				.title2(
					text: AppStrings.ExposureSubmissionResult.Antigen.noProofTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofTitle
				),
				.body(
					text: AppStrings.ExposureSubmissionResult.Antigen.noProofDesc,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofDesc
				)
			])
		}

		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.procedure,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
			),
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.Antigen.testAdded,
				description: AppStrings.ExposureSubmissionResult.Antigen.testAddedDesc,
				icon: UIImage(named: "Icons_Grey_Check"),
				hairline: .iconAttached
			),
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.testNegative,
				description: AppStrings.ExposureSubmissionResult.Antigen.testNegativeDesc,
				icon: UIImage(named: "Icons_Grey_Error"),
				hairline: .topAttached
			),
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.testRemove,
				description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
				icon: UIImage(named: "Icons_Grey_Entfernen"),
				hairline: test.certificateRequested ? .iconAttached : .none
			)
		])
		
		if test.certificateRequested {
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
					description: AppStrings.ExposureSubmissionResult.testCertificateAvailableInTheTab,
					icon: UIImage(named: "certificate-qr-light"),
					hairline: .none
				)
			)
		}
		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.furtherInfos_Title
			),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_TestAgain, spacing: .large)
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.antigenTestResult,
					configure: { view, _ in
						(view as? AntigenExposureSubmissionNegativeTestResultHeaderView)?.configure(coronaTest: test)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}


// MARK: - Expired
extension ExposureSubmissionTestResultViewModel {
	
	private var expiredTestResultSections: [DynamicSection] {
		var cells = [
			DynamicCell.title2(
				text: AppStrings.ExposureSubmissionResult.procedure,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
			)
		]

		switch coronaTest.type {
		case .pcr:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		case .antigen:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		}

		cells.append(contentsOf: [
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
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}

}


// MARK: - Invalid
extension ExposureSubmissionTestResultViewModel {
	
	private var invalidTestResultSections: [DynamicSection] {
		var cells = [
			DynamicCell.title2(
				text: AppStrings.ExposureSubmissionResult.procedure,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
			)
		]

		switch coronaTest.type {
		case .pcr:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		case .antigen:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.testAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		}

		cells.append(contentsOf: [
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
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}

// MARK: - Footer view helper
extension ExposureSubmissionTestResultViewModel {
	
	static func footerViewModel(coronaTest: CoronaTest) -> FooterViewModel {
		switch coronaTest.testResult {
		case .positive where coronaTest.keysSubmitted:
			return FooterViewModel(
				primaryButtonName:
					AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedPrimaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: true,
				isSecondaryButtonHidden: true
			)
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
	
	// swiftlint:disable:next file_length
}
