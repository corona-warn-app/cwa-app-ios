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
		coronaTestService: CoronaTestServiceProviding,
		onUpdate: @escaping () -> Void
	) {
		self.coronaTestType = coronaTestType
		self.coronaTestService = coronaTestService
		self.onUpdate = onUpdate

		setup()
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String! = ""
	@OpenCombine.Published var subtitle: String?
	@OpenCombine.Published var description: String! = ""
	@OpenCombine.Published var footnote: String?
	@OpenCombine.Published var buttonTitle: String! = ""
	@OpenCombine.Published var image: UIImage?
	@OpenCombine.Published var isDisclosureIndicatorHidden: Bool = false
	@OpenCombine.Published var isNegativeDiagnosisHidden: Bool = true
	@OpenCombine.Published var isActivityIndicatorHidden: Bool = false
	@OpenCombine.Published var isUserInteractionEnabled: Bool = false
	@OpenCombine.Published var isCellTappable: Bool = true
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.TestResultCell.unconfiguredButton

	// MARK: - Private

	private let coronaTestType: CoronaTestType
	private let coronaTestService: CoronaTestServiceProviding
	private let onUpdate: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	// swiftlint:disable:next cyclomatic_complexity
	private func setup() {
		switch coronaTestType {
		case .pcr:
			title = AppStrings.Home.TestResult.pcrTitle

			coronaTestService.pcrTest
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] pcrTest in
					guard let pcrTest = pcrTest else {
						return
					}

					self?.configure(for: pcrTest.testResult)
					self?.onUpdate()
				}
				.store(in: &subscriptions)

			coronaTestService.pcrTestResultIsLoading
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] testResultIsLoading in
					if self?.coronaTestService.pcrTest.value?.finalTestResultReceivedDate == nil {
						if testResultIsLoading {
							self?.configureLoading()
						} else if self?.isActivityIndicatorHidden == false {
							self?.configureTestResultPending()
						}
						self?.onUpdate()
					}
				}
				.store(in: &subscriptions)
		case .antigen:
			title = AppStrings.Home.TestResult.antigenTitle

			coronaTestService.antigenTest
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] antigenTest in
					guard
						let self = self,
						let antigenTest = antigenTest,
						!self.coronaTestService.antigenTestIsOutdated.value
					else {
						return
					}

					self.configure(for: antigenTest.testResult)
					self.onUpdate()
				}
				.store(in: &subscriptions)

			coronaTestService.antigenTestResultIsLoading
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] testResultIsLoading in
					if self?.coronaTestService.antigenTest.value?.finalTestResultReceivedDate == nil {
						if testResultIsLoading {
							self?.configureLoading()
						} else if self?.isActivityIndicatorHidden == false {
							self?.configureTestResultPending()
						}
						self?.onUpdate()
					}
				}
				.store(in: &subscriptions)

			coronaTestService.antigenTestIsOutdated
				.receive(on: DispatchQueue.OCombine(.main))
				.sink { [weak self] antigenTestIsOutdated in
					guard antigenTestIsOutdated else {
						return
					}

					self?.configureTestResultOutdated()
					self?.onUpdate()
				}
				.store(in: &subscriptions)
		}
	}

	private func configure(for testResult: TestResult) {
		switch testResult {
		case .invalid: configureTestResultInvalid()
		case .pending: configureTestResultPending()
		case .negative: configureTestResultNegative()
		case .positive: configureTestResultAvailable()
		case .expired: configureTestResultExpired()
		}
	}

	private func configureTestResultNegative() {
		subtitle = nil
		description = AppStrings.Home.TestResult.Negative.description

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		let dateTemplate: String
		switch coronaTestType {
		case .pcr:
			dateTemplate = AppStrings.Home.TestResult.Negative.datePCR
		case .antigen:
			dateTemplate = AppStrings.Home.TestResult.Negative.dateAntigen
		}

		let testDate = coronaTestService.coronaTest(ofType: coronaTestType)?.testDate
		let formattedTestDate = testDate.map { dateFormatter.string(from: $0) }
		footnote = formattedTestDate.map { String(format: dateTemplate, $0) }

		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Home_NegativesTestErgebnis")
		isDisclosureIndicatorHidden = false
		isNegativeDiagnosisHidden = false
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.negativePCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.negativeAntigenButton
		}
	}

	private func configureTestResultInvalid() {
		subtitle = AppStrings.Home.TestResult.Invalid.title
		description = AppStrings.Home.TestResult.Invalid.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-error")
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.invalidPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.invalidAntigenButton
		}
	}

	private func configureTestResultPending() {
		subtitle = AppStrings.Home.TestResult.Pending.title

		switch coronaTestType {
		case .pcr:
			description = AppStrings.Home.TestResult.Pending.pcrDescription
		case .antigen:
			description = AppStrings.Home.TestResult.Pending.antigenDescription
		}

		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		isDisclosureIndicatorHidden = false
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.pendingAntigenButton
		}
	}

	private func configureTestResultAvailable() {
		subtitle = AppStrings.Home.TestResult.Available.title
		description = AppStrings.Home.TestResult.Available.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.retrieveResult
		image = UIImage(named: "Illu_Hand_with_phone-error")
		isDisclosureIndicatorHidden = false
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.availableAntigenButton
		}
	}

	private func configureTestResultExpired() {
		subtitle = AppStrings.Home.TestResult.Expired.title
		description = AppStrings.Home.TestResult.Expired.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.deleteTest
		image = UIImage(named: "Illu_Hand_with_phone-pending")
		isDisclosureIndicatorHidden = true
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.expiredPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.expiredAntigenButton
		}
	}

	private func configureTestResultOutdated() {
		subtitle = AppStrings.Home.TestResult.Outdated.title
		description = AppStrings.Home.TestResult.Outdated.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.hideTest
		image = UIImage(named: "Illu_Home_OutdatedTestErgebnis")
		isDisclosureIndicatorHidden = true
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false
		accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.outdatedAntigenButton
	}

	private func configureLoading() {
		subtitle = AppStrings.Home.TestResult.Loading.title
		description = AppStrings.Home.TestResult.Loading.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "Illu_Hand_with_phone-initial")
		isDisclosureIndicatorHidden = false
		isNegativeDiagnosisHidden = true
		isActivityIndicatorHidden = false
		isUserInteractionEnabled = false
		isCellTappable = true

		switch coronaTestType {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.loadingPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.loadingAntigenButton
		}
	}

}
