//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class HomeTestResultCellModel {

	// MARK: - Init

	init(
		homeState: HomeState,
		onUpdate: @escaping () -> Void
	) {
		self.homeState = homeState

		homeState.$testResult
			.sink { [weak self] in
				switch $0 {
				case .none: self?.configureSubmit()
				case .invalid: self?.configureTestResultInvalid()
				case .pending: self?.configureTestResultPending()
				case .negative: self?.configureTestResultNegative()
				case .positive: self?.configureTestResultAvailable()
				case .expired:
					Log.info("Unsupported test result state .expired for \(String(describing: Self.self))", log: .ui)
				}

				onUpdate()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String! = AppStrings.Home.submitCardTitle
	@OpenCombine.Published var subtitle: String?
	@OpenCombine.Published var description: String! = AppStrings.Home.submitCardBody
	@OpenCombine.Published var buttonTitle: String! = AppStrings.Home.submitCardButton
	@OpenCombine.Published var image: UIImage? = UIImage(named: "Illu_Hand_with_phone-initial")
	@OpenCombine.Published var tintColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.submitCardButton

	// MARK: - Private

	private let homeState: HomeState
	private var subscriptions = Set<AnyCancellable>()

	private func configureSubmit() {
		title = AppStrings.Home.submitCardTitle
		subtitle = nil
		description = AppStrings.Home.submitCardBody
		buttonTitle = AppStrings.Home.submitCardButton
		image = UIImage(named: "Illu_Hand_with_phone-initial")
		tintColor = .enaColor(for: .textPrimary1)
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultNegative() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardNegativeTitle
		description = AppStrings.Home.resultCardNegativeDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-negativ")
		tintColor = .enaColor(for: .textSemanticGreen)
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultInvalid() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardInvalidTitle
		description = AppStrings.Home.resultCardInvalidDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultPending() {
		title = AppStrings.Home.resultCardResultUnvailableTitle
		subtitle = nil
		description = AppStrings.Home.resultCardPendingDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		tintColor = .enaColor(for: .textPrimary2)
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultAvailable() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardAvailableSubtitle
		description = AppStrings.Home.resultCardAvailableDesc
		buttonTitle = AppStrings.Home.resultCardRetrieveResultButton
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

}
