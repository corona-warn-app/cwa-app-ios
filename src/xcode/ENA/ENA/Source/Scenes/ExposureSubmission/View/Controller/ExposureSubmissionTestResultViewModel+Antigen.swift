////
// 🦠 Corona-Warn-App
//

import UIKit

extension ExposureSubmissionTestResultViewModel {
	
	func antigenTableViewModel() -> DynamicTableViewModel {
		
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
}
