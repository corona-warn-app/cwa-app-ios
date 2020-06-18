//
// Corona-Warn-App
//
// SAP SE and all other contributors
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

import Foundation
import UIKit

class HomeTestResultCellConfigurator: CollectionViewCellConfigurator {
	var identifier = UUID()

	var testResult: TestResult?

	var primaryAction: (() -> Void)?

	func configure(cell: HomeTestResultCollectionViewCell) {
		cell.delegate = self
		configure(cell: cell, for: testResult)
	}

	private func configure(cell: HomeTestResultCollectionViewCell, for testResult: TestResult?) {
		switch testResult {
		case .none: configureSubmit(cell: cell)
		case .invalid: configureTestResultInvalid(cell: cell)
		case .pending: configureTestResultPending(cell: cell)
		case .negative: configureTestResultNegative(cell: cell)
		default:
			log(message: "Unsupported state for \(String(describing: Self.self))", file: #file, line: #line, function: #function)
		}
	}

	func configureSubmit(cell: HomeTestResultCollectionViewCell) {
		cell.configure(
			title: AppStrings.Home.submitCardTitle,
			description: AppStrings.Home.submitCardBody,
			button: AppStrings.Home.submitCardButton,
			image: UIImage(named: "Illu_Hand_with_phone-initial"),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.submitCardButton
		)
	}

	private func configureTestResultNegative(cell: HomeTestResultCollectionViewCell) {
		cell.configure(
			title: AppStrings.Home.resultCardResultAvailableTitle,
			subtitle: AppStrings.Home.resultCardNegativeTitle,
			description: AppStrings.Home.resultCardNegativeDesc,
			button: AppStrings.Home.resultCardShowResultButton,
			image: UIImage(named: "Illu_Hand_with_phone-negativ"),
			tintColor: .enaColor(for: .textSemanticGreen),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.resultCardShowResultButton
		)
	}

	private func configureTestResultInvalid(cell: HomeTestResultCollectionViewCell) {
		cell.configure(
			title: AppStrings.Home.resultCardResultAvailableTitle,
			subtitle: AppStrings.Home.resultCardInvalidTitle,
			description: AppStrings.Home.resultCardInvalidDesc,
			button: AppStrings.Home.resultCardShowResultButton,
			image: UIImage(named: "Illu_Hand_with_phone-error"),
			tintColor: .enaColor(for: .textSemanticGray),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.resultCardShowResultButton
		)
	}

	private func configureTestResultPending(cell: HomeTestResultCollectionViewCell) {
		cell.configure(
			title: AppStrings.Home.resultCardResultUnvailableTitle,
			description: AppStrings.Home.resultCardPendingDesc,
			button: AppStrings.Home.resultCardShowResultButton,
			image: UIImage(named: "Illu_Hand_with_phone-pending"),
			tintColor: .enaColor(for: .textPrimary2),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.resultCardShowResultButton
		)
	}
}

extension HomeTestResultCellConfigurator: HomeTestResultCollectionViewCellDelegate {
	func testResultCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeTestResultCollectionViewCell) {
		primaryAction?()
	}
}
