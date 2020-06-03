//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit

final class HomeFindingPositiveRiskCellConfigurator: HomeRiskCellConfigurator {

	let identifier = UUID()

	var nextAction: (() -> Void)?

	// MARK: Configuration

	func configure(cell: RiskFindingPositiveCollectionViewCell) {

		cell.delegate = self

		let title = AppStrings.Home.findingPositiveCardTitle
		let titleColor: UIColor = UIColor.black
		cell.configureTitle(title: title, titleColor: titleColor)
		cell.configureChevron(image: UIImage(systemName: "chevron.right.circle.fill"), tintColor: .preferredColor(for: .chevron))
		
		let statusTitle = AppStrings.Home.findingPositiveCardStatusTitle
		let statusSubtitle = AppStrings.Home.findingPositiveCardStatusSubtitle
		let statusImageName = "Illu_Submission_PositivTestErgebnis"
		cell.configureStatus(title: statusTitle, subtitle: statusSubtitle, titleColor: titleColor, lineColor: .preferredColor(for: .brandRed), imageName: statusImageName)

		let noteTitle = AppStrings.Home.findingPositiveCardNoteTitle
		cell.configureNoteLabel(title: noteTitle)

		let iconColor: UIColor = .preferredColor(for: .brandRed)
		let phoneTitle = AppStrings.Home.findingPositivePhoneItemTitle
		let phoneItem = HomeRiskImageItemViewConfigurator(title: phoneTitle, titleColor: titleColor, iconImageName: "Icons - Hotline", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		phoneItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)

		let homeTitle = AppStrings.Home.findingPositiveHomeItemTitle
		let homeItem = HomeRiskImageItemViewConfigurator(title: homeTitle, titleColor: titleColor, iconImageName: "Icons - Home", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		homeItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)

		let shareTitle = AppStrings.Home.findingPositiveShareItemTitle
		let shareItem = HomeRiskImageItemViewConfigurator(title: shareTitle, titleColor: titleColor, iconImageName: "Icons - Warnen", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		shareItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)

		cell.configureNoteRiskViews(cellConfigurators: [phoneItem, homeItem, shareItem])


		let buttonTitle = AppStrings.Home.findingPositiveCardButton

		cell.configureNextButton(
			title: buttonTitle,
			color: .white,
			backgroundColor: .preferredColor(for: .tint)
		)

		let backgroundColor = UIColor.preferredColor(for: .backgroundPrimary)
		cell.configureBackgroundColor(color: backgroundColor)
	}
}

extension HomeFindingPositiveRiskCellConfigurator: RiskFindingPositiveCollectionViewCellDelegate {
	func nextButtonTapped(cell: RiskFindingPositiveCollectionViewCell) {
		nextAction?()
	}
}
