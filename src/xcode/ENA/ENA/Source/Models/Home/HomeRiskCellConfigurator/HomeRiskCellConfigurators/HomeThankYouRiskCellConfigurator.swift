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

final class HomeThankYouRiskCellConfigurator: HomeRiskCellConfigurator {

	let identifier = UUID()

	// MARK: Configuration

	func configure(cell: RiskThankYouCollectionViewCell) {

		cell.removeAllArrangedSubviews()

		let title = AppStrings.Home.thankYouCardTitle
		let titleColor: UIColor = UIColor.black
		cell.configureTitle(title: title, titleColor: titleColor)

		let imageName = "Illu_Submission_VielenDank"
		cell.configureImage(imageName: imageName)

		let body = AppStrings.Home.thankYouCardBody
		cell.configureBody(text: body, bodyColor: titleColor)

		let noteTitle = AppStrings.Home.thankYouCardNoteTitle
		cell.configureNoteLabel(title: noteTitle)

		let iconColor: UIColor = .preferredColor(for: .brandRed)
		let phoneTitle = AppStrings.Home.thankYouCardPhoneItemTitle
		let phoneItem = HomeRiskImageItemViewConfigurator(title: phoneTitle, titleColor: titleColor, iconImageName: "Icons - Hotline", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		phoneItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)

		let homeTitle = AppStrings.Home.thankYouCardHomeItemTitle
		let homeItem = HomeRiskImageItemViewConfigurator(title: homeTitle, titleColor: titleColor, iconImageName: "Icons - Home", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		homeItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
		cell.configureNoteRiskViews(cellConfigurators: [phoneItem, homeItem])


		let furtherInfoTitle = AppStrings.Home.thankYouCardFurtherInfoItemTitle
		cell.configureFurtherInfoLabel(title: furtherInfoTitle)

		let info1Text = AppStrings.Home.thankYouCard14DaysItemTitle
		let info1 = HomeRiskListItemViewConfigurator(text: info1Text, titleColor: titleColor)
		let info2Text = AppStrings.Home.thankYouCardContactsItemTitle
		let info2 = HomeRiskListItemViewConfigurator(text: info2Text, titleColor: titleColor)
		let info3Text = AppStrings.Home.thankYouCardAppItemTitle
		let info3 = HomeRiskListItemViewConfigurator(text: info3Text, titleColor: titleColor)
		let info4Text = AppStrings.Home.thankYouCardNoSymptomsItemTitle
		let info4 = HomeRiskListItemViewConfigurator(text: info4Text, titleColor: titleColor)
		cell.configureFurtherInfoRiskViews(cellConfigurators: [info1, info2, info3, info4])

		let backgroundColor = UIColor.preferredColor(for: .backgroundPrimary)
		cell.configureBackgroundColor(color: backgroundColor)
	}
}
