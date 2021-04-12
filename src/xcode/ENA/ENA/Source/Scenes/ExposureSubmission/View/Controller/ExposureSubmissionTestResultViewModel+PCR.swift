////
// 🦠 Corona-Warn-App
//

import UIKit

extension ExposureSubmissionTestResultViewModel {
	
	func pcrTableViewModel() -> DynamicTableViewModel {
		
		let sections: [DynamicSection]
		
		switch coronaTest.testResult {
		case .positive:
			sections = coronaTest.isSubmissionConsentGiven ? positiveTestResultSectionsWithSubmissionConsent : positiveTestResultSectionsWithoutSubmissionConsent
		case .negative:
			sections = negativeTestResultSections
		case .invalid:
			sections = invalidTestResultSections
		case .pending:
			sections = pendingTestResultSections
		case .expired:
			sections = expiredTestResultSections
		}
		
		return DynamicTableViewModel(sections)
	}
	
	private var pendingTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
					}
				),
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
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
						hairline: .none
					)]
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
								self?.footerViewModel?.setLoadingIndicator(true, disable: isLoading, button: .primary)
								self?.footerViewModel?.setLoadingIndicator(true, disable: isLoading, button: .secondary)
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
	
	/// This is the positive result section which will be shown, if the user
	/// has NOT GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithoutSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
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
	
	/// This is the positive result section which will be shown, if the user
	/// has GIVEN submission consent to share the positive test result with others
	private var positiveTestResultSectionsWithSubmissionConsent: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
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
	
	private var negativeTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
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
	
	private var expiredTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
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
	
	private var invalidTestResultSections: [DynamicSection] {
		[
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest, timeStamp: self.timeStamp)
					}
				),
				separators: .none,
				cells: [
					.title2(text: AppStrings.ExposureSubmissionResult.procedure,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure),
					
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.PCR.testAdded,
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
}
