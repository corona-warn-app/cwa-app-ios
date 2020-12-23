//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class HomeTestResultCellConfigurator: CollectionViewCellConfigurator {

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
		case .positive: configureTestResultAvailable(cell: cell)
		case .expired:
			Log.info("Unsupported test result state .expired for \(String(describing: Self.self))", log: .ui)
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

	private func configureTestResultAvailable(cell: HomeTestResultCollectionViewCell) {
		cell.configure(
			title: AppStrings.Home.resultCardResultAvailableTitle,
			subtitle: AppStrings.Home.resultCardAvailableSubtitle,
			description: AppStrings.Home.resultCardAvailableDesc,
			button: AppStrings.Home.resultCardRetrieveResultButton,
			image: UIImage(named: "Illu_Hand_with_phone-error"),
			tintColor: .enaColor(for: .textSemanticGray),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.resultCardShowResultButton
		)
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(testResult)
	}

	static func == (lhs: HomeTestResultCellConfigurator, rhs: HomeTestResultCellConfigurator) -> Bool {
		lhs.testResult == rhs.testResult
	}
}

extension HomeTestResultCellConfigurator: HomeTestResultCollectionViewCellDelegate {
	func testResultCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeTestResultCollectionViewCell) {
		primaryAction?()
	}
}
