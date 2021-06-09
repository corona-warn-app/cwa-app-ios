////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardViewModel {

	// MARK: - Init

	init(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue(cardRawValue: keyFigureCard.header.cardID)

			primaryTrendImage = primaryFigure.trendImage
			primaryTrendImageTintColor = primaryFigure.trendTintColor
			primaryTrendAccessibilityLabel = primaryFigure.trendAccessibilityLabel
			primaryTrendAccessibilityValue = primaryFigure.trendAccessibilityValue
		}

		if let secondaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .secondary }) {
			secondaryValue = secondaryFigure.formattedValue()

			secondaryTrendImage = secondaryFigure.trendImage
			secondaryTrendImageTintColor = secondaryFigure.trendTintColor
			secondaryTrendAccessibilityLabel = secondaryFigure.trendAccessibilityLabel
			secondaryTrendAccessibilityValue = secondaryFigure.trendAccessibilityValue
		}

		if let tertiaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .tertiary }) {
			tertiaryValue = tertiaryFigure.formattedValue()
		}

		switch HomeStatisticsCard(rawValue: keyFigureCard.header.cardID) {
		case .infections:
			setupInfections(for: keyFigureCard)
		case .incidence:
			setupIncidence(for: keyFigureCard)
		case .keySubmissions:
			setupKeySubmissions(for: keyFigureCard)
		case .reproductionNumber:
			setupReproductionNumber(for: keyFigureCard)
		case .atLeastOneVaccinatedPerson:
			setupAtLeastOneVaccinatedPerson(for: keyFigureCard)
		case .completeVaccinatedPeople:
			setupCompleteVaccinatedPeople(for: keyFigureCard)
		case .appliedVaccinationsDoseRates:
			setupAppliedVaccinationsDoseRates(for: keyFigureCard)

		case .none:
			Log.info("Statistics card ID \(keyFigureCard.header.cardID) is not supported", log: .ui)
		}
	}
	// MARK: - Internal

	@OpenCombine.Published private(set) var title: String?

	@OpenCombine.Published private(set) var illustrationImage: UIImage!

	@OpenCombine.Published private(set) var primaryTitle: String?
	@OpenCombine.Published private(set) var primaryValue: String?
	@OpenCombine.Published private(set) var primaryTrendImage: UIImage?
	@OpenCombine.Published private(set) var primaryTrendImageTintColor: UIColor?
	@OpenCombine.Published private(set) var primaryTrendAccessibilityLabel: String?
	@OpenCombine.Published private(set) var primaryTrendAccessibilityValue: String?

	@OpenCombine.Published private(set) var primarySubtitle: String?

	@OpenCombine.Published private(set) var secondaryTitle: String?
	@OpenCombine.Published private(set) var secondaryValue: String?
	@OpenCombine.Published private(set) var secondarySubtitle: String?
	@OpenCombine.Published private(set) var secondaryTrendImage: UIImage?
	@OpenCombine.Published private(set) var secondaryTrendImageTintColor: UIColor?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityLabel: String?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityValue: String?

	@OpenCombine.Published private(set) var tertiaryTitle: String?
	@OpenCombine.Published private(set) var tertiaryValue: String?


	var titleAccessiblityIdentifier: String?
	var infoButtonAccessibilityIdentifier: String?
	
	// MARK: - Private

	private func setupInfections(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Infections.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.Infections.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Infections.infoButton
		illustrationImage = UIImage(named: "Illu_Bestaetigte_Neuinfektionen")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.Infections.today,
				yesterdayString: AppStrings.Statistics.Card.Infections.yesterday,
				otherDateString: AppStrings.Statistics.Card.Infections.date
			)
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.Infections.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.Infections.tertiaryLabelTitle
		}
	}

	private func setupKeySubmissions(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.KeySubmissions.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton
		illustrationImage = UIImage(named: "Illu_Warnende_Personen")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.KeySubmissions.today,
				yesterdayString: AppStrings.Statistics.Card.KeySubmissions.yesterday,
				otherDateString: AppStrings.Statistics.Card.KeySubmissions.date
			)
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.KeySubmissions.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.KeySubmissions.tertiaryLabelTitle
		}
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromCWA
	}

	private func setupIncidence(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Incidence.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.Incidence.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Incidence.infoButton
		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.Incidence.today,
				yesterdayString: AppStrings.Statistics.Card.Incidence.yesterday,
				otherDateString: AppStrings.Statistics.Card.Incidence.date
			)
		}

		secondarySubtitle = AppStrings.Statistics.Card.Incidence.secondaryLabelTitle
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromNationWide
	}

	private func setupReproductionNumber(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.ReproductionNumber.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton
		illustrationImage = UIImage(named: "Illu_7-Tage-R-Wert")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.ReproductionNumber.today,
				yesterdayString: AppStrings.Statistics.Card.ReproductionNumber.yesterday,
				otherDateString: AppStrings.Statistics.Card.ReproductionNumber.date
			)
		}

		secondarySubtitle = AppStrings.Statistics.Card.ReproductionNumber.secondaryLabelTitle
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromNationWide
	}

	private func setupAtLeastOneVaccinatedPerson(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.AtleastOneVaccinated.title
		illustrationImage = UIImage(named: "AtleastOneVaccinated")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.AtleastOneVaccinated.today,
				yesterdayString: AppStrings.Statistics.Card.AtleastOneVaccinated.yesterday,
				otherDateString: AppStrings.Statistics.Card.AtleastOneVaccinated.date
			)
		}
		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.AtleastOneVaccinated.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.AtleastOneVaccinated.tertiaryLabelTitle
		}
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromNationWide
		secondarySubtitle = AppStrings.Statistics.Card.AtleastOneVaccinated.secondarySubtitle
	}

	private func setupCompleteVaccinatedPeople(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.FullyVaccinated.title
		illustrationImage = UIImage(named: "FullyVaccinated")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.FullyVaccinated.today,
				yesterdayString: AppStrings.Statistics.Card.FullyVaccinated.yesterday,
				otherDateString: AppStrings.Statistics.Card.FullyVaccinated.date
			)
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.FullyVaccinated.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.FullyVaccinated.tertiaryLabelTitle
		}
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromNationWide
		secondarySubtitle = AppStrings.Statistics.Card.FullyVaccinated.secondarySubtitle
	}
	
	private func setupAppliedVaccinationsDoseRates(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.DoseRates.title
		illustrationImage = UIImage(named: "Doses")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.DoseRates.today,
				yesterdayString: AppStrings.Statistics.Card.DoseRates.yesterday,
				otherDateString: AppStrings.Statistics.Card.DoseRates.date
			)
		}
		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.DoseRates.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.DoseRates.tertiaryLabelTitle
		}
		primarySubtitle = AppStrings.Statistics.Card.KeySubmissions.fromNationWide
	}
}

private extension Date {

	func formatted(todayString: String, yesterdayString: String, otherDateString: String) -> String {
		if Calendar.current.isDate(self, inSameDayAs: Date()) {
			return todayString
		}

		if let yesterday = Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()),
		   Calendar.current.isDate(self, inSameDayAs: yesterday) {
			return yesterdayString
		}

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none

		return String(format: otherDateString, dateFormatter.string(from: self))
	}

}
