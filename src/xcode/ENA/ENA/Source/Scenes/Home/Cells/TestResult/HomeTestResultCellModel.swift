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
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] testResult in
				self?.configure(for: testResult)
				onUpdate()
			}
			.store(in: &subscriptions)

		homeState.$testResultIsLoading
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] testResultIsLoading in
				if testResultIsLoading {
					self?.configureLoading()
					onUpdate()
				}
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
	@OpenCombine.Published var isActivityIndicatorHidden: Bool = false
	@OpenCombine.Published var isUserInteractionEnabled: Bool = false
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.submitCardButton

	// MARK: - Private

	private let homeState: HomeState
	private var subscriptions = Set<AnyCancellable>()

	// swiftlint:disable:next cyclomatic_complexity
	private func configure(for testResult: TestResult?) {
		#if DEBUG
		if isUITesting {
			// adding this for launch arguments to fake test results on home screen
			if UserDefaults.standard.string(forKey: "showInvalidTest") == "YES" {
				configureTestResultInvalid()
			} else if UserDefaults.standard.string(forKey: "showPendingTest") == "YES" {
				configureTestResultPending()
			} else if UserDefaults.standard.string(forKey: "showNegativeTest") == "YES" {
				configureTestResultNegative()
			} else if UserDefaults.standard.string(forKey: "showPositiveTest") == "YES" {
				configureTestResultAvailable()
			}
		}
		#endif

		switch testResult {
		case .none: configureSubmit()
		case .invalid: configureTestResultInvalid()
		case .pending: configureTestResultPending()
		case .negative: configureTestResultNegative()
		case .positive: configureTestResultAvailable()
		// Expired tests are shown as pending
		case .expired: configureTestResultPending()
		}
	}

	private func configureSubmit() {
		title = AppStrings.Home.submitCardTitle
		subtitle = nil
		description = AppStrings.Home.submitCardBody
		buttonTitle = AppStrings.Home.submitCardButton
		image = UIImage(named: "Illu_Hand_with_phone-initial")
		tintColor = .enaColor(for: .textPrimary1)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureLoading() {
		title = AppStrings.Home.resultCardLoadingTitle
		subtitle = nil
		description = AppStrings.Home.resultCardLoadingBody
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-initial")
		tintColor = .enaColor(for: .textPrimary1)
		isActivityIndicatorHidden = false
		isUserInteractionEnabled = false
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultNegative() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardNegativeTitle
		description = AppStrings.Home.resultCardNegativeDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-negativ")
		tintColor = .enaColor(for: .textSemanticGreen)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultInvalid() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardInvalidTitle
		description = AppStrings.Home.resultCardInvalidDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultPending() {
		title = AppStrings.Home.resultCardResultUnvailableTitle
		subtitle = nil
		description = AppStrings.Home.resultCardPendingDesc
		buttonTitle = AppStrings.Home.resultCardShowResultButton
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		tintColor = .enaColor(for: .textPrimary2)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

	private func configureTestResultAvailable() {
		title = AppStrings.Home.resultCardResultAvailableTitle
		subtitle = AppStrings.Home.resultCardAvailableSubtitle
		description = AppStrings.Home.resultCardAvailableDesc
		buttonTitle = AppStrings.Home.resultCardRetrieveResultButton
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.resultCardShowResultButton
	}

}
