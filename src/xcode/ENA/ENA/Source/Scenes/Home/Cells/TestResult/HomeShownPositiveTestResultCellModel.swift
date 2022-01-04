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

		switch coronaTestType {
		case .pcr:
			title = AppStrings.Home.TestResult.pcrTitle

			coronaTestService.$pcrTest
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

	let noteTitle = AppStrings.Home.TestResult.ShownPositive.noteTitle
	let buttonTitle = AppStrings.Home.TestResult.ShownPositive.button
	let removeTestButtonTitle = AppStrings.Home.TestResult.ShownPositive.removeTestButton

	@OpenCombine.Published var statusFootnote: String?
	@OpenCombine.Published var homeItemViewModels: [HomeImageItemViewModel] = []
	@OpenCombine.Published var isWarnOthersButtonHidden = false
	@OpenCombine.Published var isRemoveTestButtonHidden = false
	@OpenCombine.Published var accessibilityIdentifier: String?

	// MARK: - Private

	private let coronaTestType: CoronaTestType
	private var subscriptions = Set<AnyCancellable>()

	private func configure(for coronaTest: CoronaTest) {
		let dateTemplate: String
		switch coronaTestType {
		case .pcr:
			dateTemplate = AppStrings.Home.TestResult.ShownPositive.statusDatePCR
		case .antigen:
			dateTemplate = AppStrings.Home.TestResult.ShownPositive.statusDateAntigen
		}

		let formattedTestDate = DateFormatter.localizedString(from: coronaTest.testDate, dateStyle: .short, timeStyle: .none)
		statusFootnote = String(format: dateTemplate, formattedTestDate)

		var homeItemViewModels = [HomeImageItemViewModel]()

		if coronaTest.type == .pcr {
			homeItemViewModels.append(contentsOf: [
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemPCR0,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Home",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				),
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemPCR1,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Hotline",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				),
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemPCR2,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Red Plus",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				)
			])
		} else if coronaTest.type == .antigen {
			homeItemViewModels.append(contentsOf: [
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemRAT0,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Home",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				),
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemRAT1,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Test Tube",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				),
				HomeImageItemViewModel(
					title: AppStrings.Home.TestResult.ShownPositive.itemRAT2,
					titleColor: .enaColor(for: .textPrimary1),
					iconImageName: "Icons - Hotline",
					iconTintColor: .enaColor(for: .riskHigh),
					color: .clear,
					separatorColor: .clear,
					containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
				)
			])
		}

		self.homeItemViewModels = homeItemViewModels

		isWarnOthersButtonHidden = coronaTest.keysSubmitted
		isRemoveTestButtonHidden = coronaTest.keysSubmitted
		
		switch (coronaTest.type, coronaTest.keysSubmitted) {
		case (.pcr, false):
			accessibilityIdentifier = AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.pcrCell
		case (.pcr, true):
			accessibilityIdentifier = AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.submittedPCRCell
		case (.antigen, false):
			accessibilityIdentifier = AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.antigenCell
		case (.antigen, true):
			accessibilityIdentifier = AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.submittedAntigenCell
		}
	}

}
