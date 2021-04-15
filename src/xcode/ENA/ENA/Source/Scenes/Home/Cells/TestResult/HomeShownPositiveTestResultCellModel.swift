//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeShownPositiveTestResultCellModel {

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

					self?.configure(for: .pcr(pcrTest))
					onUpdate()
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

					self?.configure(for: .antigen(antigenTest))
					onUpdate()
				}
				.store(in: &subscriptions)
		}
	}

	// MARK: - Internal

	let title: String

	let statusTitle = AppStrings.Home.TestResult.ShownPositive.statusTitle
	let statusSubtitle = AppStrings.Home.TestResult.ShownPositive.statusSubtitle

	var statusFootnote: String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		let dateTemplate: String
		switch coronaTestType {
		case .pcr:
			dateTemplate = AppStrings.Home.TestResult.ShownPositive.statusDatePCR
		case .antigen:
			dateTemplate = AppStrings.Home.TestResult.ShownPositive.statusDateAntigen
		}

		let testDate = coronaTestService.coronaTest(ofType: coronaTestType)?.testDate
		let formattedTestDate = testDate.map { dateFormatter.string(from: $0) }
		return formattedTestDate.map { String(format: dateTemplate, $0) }
	}

	let noteTitle = AppStrings.Home.TestResult.ShownPositive.noteTitle

	let buttonTitle = AppStrings.Home.TestResult.ShownPositive.button

	let iconColor: UIColor = .enaColor(for: .riskHigh)

	@OpenCombine.Published var homeItemViewModels: [HomeItemViewModel] = []

	@OpenCombine.Published var isButtonHidden = false

	func configure(for coronaTest: CoronaTest) {
		var homeItemViewModels = [HomeItemViewModel]()

		if coronaTest.type == .antigen {
			homeItemViewModels.append(
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.verifyItemTitle,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Test Tube",
					iconTintColor: iconColor,
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				)
			)
		}

		homeItemViewModels.append(contentsOf: [
			HomeImageItemViewModel(
				title: AppStrings.Home.TestResult.ShownPositive.phoneItemTitle,
				titleColor: .enaColor(for: .textPrimary1),
				iconImageName: "Icons - Hotline",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.TestResult.ShownPositive.homeItemTitle,
				titleColor: .enaColor(for: .textPrimary1),
				iconImageName: "Icons - Home",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			)
		])

		if !coronaTest.keysSubmitted {
			homeItemViewModels.append(
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.shareItemTitle,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Warnen",
					iconTintColor: iconColor,
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				)
			)
		}

		self.homeItemViewModels = homeItemViewModels

		isButtonHidden = coronaTest.keysSubmitted
	}

	// MARK: - Private

	private let coronaTestType: CoronaTestType
	private let coronaTestService: CoronaTestService
	private var subscriptions = Set<AnyCancellable>()

}
