//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class HomeTestResultCellModel {

	// MARK: - Init

	init(
		coronaTestType: CoronaTestType,
		coronaTestService: CoronaTestService,
		onUpdate: @escaping () -> Void
	) {
		self.coronaTestType = coronaTestType
		self.coronaTestService = coronaTestService

		switch coronaTestType {
		case .pcr:
			title = AppStrings.Home.TestResult.pcrTitle

			coronaTestService.$pcrTest
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] pcrTest in
					guard let pcrTest = pcrTest else {
						return
					}

					self?.configure(for: pcrTest.testResult)
				}
				.store(in: &subscriptions)

			coronaTestService.$pcrTestResultIsLoading
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] testResultIsLoading in
					if testResultIsLoading && self?.coronaTestService.pcrTest?.finalTestResultReceivedDate == nil {
						self?.configureLoading()
						onUpdate()
					}
				}
				.store(in: &subscriptions)
		case .antigen:
			title = AppStrings.Home.TestResult.antigenTitle

			coronaTestService.$antigenTest
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] antigenTest in
					guard let antigenTest = antigenTest else {
						return
					}

					self?.configure(for: antigenTest.testResult)
				}
				.store(in: &subscriptions)

			coronaTestService.$antigenTestResultIsLoading
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] testResultIsLoading in
					if testResultIsLoading && self?.coronaTestService.antigenTest?.finalTestResultReceivedDate == nil {
						self?.configureLoading()
						onUpdate()
					}
				}
				.store(in: &subscriptions)
		}
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String! = ""
	@OpenCombine.Published var subtitle: String?
	@OpenCombine.Published var description: String! = ""
	@OpenCombine.Published var buttonTitle: String! = ""
	@OpenCombine.Published var image: UIImage?
	@OpenCombine.Published var tintColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published var isActivityIndicatorHidden: Bool = false
	@OpenCombine.Published var isUserInteractionEnabled: Bool = false
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.submitCardButton

	// MARK: - Private

	private let coronaTestType: CoronaTestType
	private let coronaTestService: CoronaTestService
	private var subscriptions = Set<AnyCancellable>()

	private func configure(for testResult: TestResult) {
		#if DEBUG
		if isUITesting {
			// adding this for launch arguments to fake test results on home screen
			if UserDefaults.standard.string(forKey: "showInvalidTestResult") == "YES" {
				configureTestResultInvalid()
				return
			} else if UserDefaults.standard.string(forKey: "showPendingTestResult") == "YES" {
				configureTestResultPending()
				return
			} else if UserDefaults.standard.string(forKey: "showNegativeTestResult") == "YES" {
				configureTestResultNegative()
				return
			} else if UserDefaults.standard.string(forKey: "showLoadingTestResult") == "YES" {
				configureLoading()
				return
			}
		}
		#endif

		switch testResult {
		case .invalid: configureTestResultInvalid()
		case .pending: configureTestResultPending()
		case .negative: configureTestResultNegative()
		case .positive: configureTestResultAvailable()
		case .expired: configureTestResultExpired()
		}
	}

	private func configureLoading() {
		subtitle = AppStrings.Home.TestResult.Loading.title
		description = AppStrings.Home.TestResult.Loading.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-initial")
		tintColor = .enaColor(for: .textPrimary1)
		isActivityIndicatorHidden = false
		isUserInteractionEnabled = false
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultNegative() {
		subtitle = AppStrings.Home.TestResult.Negative.title
		description = AppStrings.Home.TestResult.Negative.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-negativ")
		tintColor = .enaColor(for: .textSemanticGreen)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultInvalid() {
		subtitle = AppStrings.Home.TestResult.Invalid.title
		description = AppStrings.Home.TestResult.Invalid.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultPending() {
		subtitle = AppStrings.Home.TestResult.Pending.title

		switch coronaTestType {
		case .pcr:
			description = AppStrings.Home.TestResult.Pending.pcrDescription
		case .antigen:
			description = AppStrings.Home.TestResult.Pending.antigenDescription
		}

		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		tintColor = .enaColor(for: .textPrimary2)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultAvailable() {
		subtitle = AppStrings.Home.TestResult.Available.title
		description = AppStrings.Home.TestResult.Available.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-error")
		tintColor = .enaColor(for: .textSemanticGray)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultExpired() {
		subtitle = AppStrings.Home.TestResult.Expired.title
		description = AppStrings.Home.TestResult.Expired.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		tintColor = .enaColor(for: .textPrimary2)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

	private func configureTestResultOutdated() {
		subtitle = AppStrings.Home.TestResult.Expired.title
		description = AppStrings.Home.TestResult.Expired.description
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		tintColor = .enaColor(for: .textPrimary2)
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton
	}

}
