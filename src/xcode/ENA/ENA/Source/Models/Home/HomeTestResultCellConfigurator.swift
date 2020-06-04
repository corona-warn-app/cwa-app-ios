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

import Foundation
import UIKit

class HomeTestResultCellConfigurator: CollectionViewCellConfigurator {

	let identifier = UUID()

	var buttonAction: (() -> Void)?
	var testResult = TestResult.pending

	func configure(cell: HomeTestResultCell) {
		cell.delegate = self
		updateState(cell)
	}

	func updateState(_ cell: HomeTestResultCell) {
		switch testResult {
		case .invalid:
			configureTestResultInvalid(cell: cell)
		case .pending:
			configureTestResultPending(cell: cell)
		case .negative:
			configureTestResultNegative(cell: cell)
		default:
			appLogger.log(message: "Unsupported state", file: #file, line: #line, function: #function)
		}
	}

	private func configureTestResultNegative(cell: HomeTestResultCell) {
		cell.image.image = UIImage(named: "Illu_Hand_with_phone-negativ")
		cell.title.text = AppStrings.Home.resultCardResultAvailableTitle
		cell.result.text = AppStrings.Home.resultCardNegativeTitle
		cell.result.textColor = .preferredColor(for: .positiveRisk)
		cell.body.text = AppStrings.Home.resultCardNegativeDesc
		configureResultsButton(for: cell)
	}

	private func configureTestResultInvalid(cell: HomeTestResultCell) {
		cell.image.image = UIImage(named: "Illu_Hand_with_phone-error")
		cell.title.text = AppStrings.Home.resultCardResultAvailableTitle
		cell.result.text = AppStrings.Home.resultCardInvalidTitle
		cell.result.textColor = .preferredColor(for: .separator)
		cell.body.text = AppStrings.Home.resultCardInvalidDesc
		configureResultsButton(for: cell)
	}

	private func configureTestResultPending(cell: HomeTestResultCell) {
		cell.image.image = UIImage(named: "Illu_Hand_with_phone-pending")
		cell.title.text = AppStrings.Home.resultCardResultUnvailableTitle
		cell.result.text = ""
		cell.result.textColor = .preferredColor(for: .chevron)
		cell.body.text = AppStrings.Home.resultCardPendingDesc
		configureResultsButton(for: cell)
	}

	private func configureResultsButton(for cell: HomeTestResultCell) {
		let title = AppStrings.Home.resultCardShowResultButton
		cell.button.isEnabled = isButtonActive()
		cell.button.setTitle(title, for: .normal)
		guard let buttonLabel = cell.button.titleLabel else { return }
		buttonLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
		buttonLabel.adjustsFontForContentSizeCategory = true
		buttonLabel.lineBreakMode = .byWordWrapping
	}

	private func isButtonActive() -> Bool {
		switch self.testResult {
		case .pending:
			return false
		default:
			return true
		}
	}
}

extension HomeTestResultCellConfigurator: HomeCardCellButtonDelegate {
	func buttonTapped(cell: HomeCardCollectionViewCell) {
		buttonAction?()
	}
}
