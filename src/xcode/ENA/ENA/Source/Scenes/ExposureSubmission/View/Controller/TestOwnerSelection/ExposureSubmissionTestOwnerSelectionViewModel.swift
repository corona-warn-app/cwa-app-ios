//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionTestOwnerSelectionViewModel {
	
	// MARK: - Init

	init(
		onTestOwnerSelection: @escaping(TestOwner) -> Void
	) {
		self.onTestOwnerSelection = onTestOwnerSelection
	}
	
	// MARK: - Internal
enum TestOwner {
	case user
	case familyMember
}
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.subheadline(
						text: AppStrings.ExposureSubmission.TestOwnerSelection.description,
						color: .enaColor(for: .textPrimary2)
					),
					.identifier(
						ExposureSubmissionTestOwnerCell.dynamicTableViewCellReuseIdentifier,
						action: .execute { _, _ in
							self.onTestOwnerSelection(.user)
						},
						configure: { _, cell, _ in
							guard let cell = cell as? ExposureSubmissionTestOwnerCell else {
								fatalError("could not initialize cell of type `ExposureSubmissionTestOwnerCell`")
							}

							cell.configure(
								headline: AppStrings.ExposureSubmission.TestOwnerSelection.userHeadline,
								subheadline: AppStrings.ExposureSubmission.TestOwnerSelection.userSubheadline,
								iconImage: UIImage(named: "Icons_User"),
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.userButton
							)
						}),
					.identifier(
						ExposureSubmissionTestOwnerCell.dynamicTableViewCellReuseIdentifier,
						action: .execute { _, _ in
							self.onTestOwnerSelection(.familyMember)
						},
						configure: { _, cell, _ in
							guard let cell = cell as? ExposureSubmissionTestOwnerCell else {
								fatalError("could not initialize cell of type `ExposureSubmissionTestOwnerCell`")
							}

							cell.configure(
								headline: AppStrings.ExposureSubmission.TestOwnerSelection.familyMemberHeadline,
								subheadline: AppStrings.ExposureSubmission.TestOwnerSelection.familyMemberSubheadline,
								iconImage: UIImage(named: "Icons_FamilyMembers"),
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.familyMemberButton
							)
						})
				].compactMap { $0 }
			)
		])
	}
	
	// MARK: - Private

	private let onTestOwnerSelection: (TestOwner) -> Void
}
