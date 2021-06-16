////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardViewModel {

	// MARK: - Init
	
	// swiftlint:disable cyclomatic_complexity
	init(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryTrendImage = primaryFigure.trendImage
			primaryTrendImageTintColor = primaryFigure.trendTintColor
			primaryTrendAccessibilityLabel = primaryFigure.trendAccessibilityLabel
			primaryTrendAccessibilityValue = primaryFigure.trendAccessibilityValue
		}

		if let secondaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .secondary }) {
			secondaryValue = secondaryFigure.formattedValue

			secondaryTrendImage = secondaryFigure.trendImage
			secondaryTrendImageTintColor = secondaryFigure.trendTintColor
			secondaryTrendAccessibilityLabel = secondaryFigure.trendAccessibilityLabel
			secondaryTrendAccessibilityValue = secondaryFigure.trendAccessibilityValue
		}

		if let tertiaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .tertiary }) {
			tertiaryValue = tertiaryFigure.formattedValue
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
		case .fullyVaccinatedPeople:
			setupFullyVaccinatedPeople(for: keyFigureCard)
		case .appliedVaccinationsDoseRates:
			setupAppliedVaccinationsDoseRates(for: keyFigureCard)
		case .none:
			Log.info("Statistics card ID \(keyFigureCard.header.cardID) is not supported", log: .ui)
		}
	}
	
	// swiftlint:enable cyclomatic_complexity
	// MARK: - Internal
	
	@OpenCombine.Published private(set) var title: String?
	@OpenCombine.Published private(set) var subtitle: String?

	@OpenCombine.Published private(set) var illustrationImage: UIImage!

	@OpenCombine.Published private(set) var primaryTitle: String?
	@OpenCombine.Published private(set) var primaryValue: String?
	@OpenCombine.Published private(set) var primarySubtitle: String?
	@OpenCombine.Published private(set) var primaryTrendImage: UIImage?
	@OpenCombine.Published private(set) var primaryTrendImageTintColor: UIColor?
	@OpenCombine.Published private(set) var primaryTrendAccessibilityLabel: String?
	@OpenCombine.Published private(set) var primaryTrendAccessibilityValue: String?
	@OpenCombine.Published private(set) var secondaryTitle: String?
	@OpenCombine.Published private(set) var secondaryValue: String?
	@OpenCombine.Published private(set) var secondaryTrendImage: UIImage?
	@OpenCombine.Published private(set) var secondaryTrendImageTintColor: UIColor?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityLabel: String?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityValue: String?

	@OpenCombine.Published private(set) var tertiaryTitle: String?
	@OpenCombine.Published private(set) var tertiaryValue: String?

	@OpenCombine.Published private(set) var footnote: String?

	var titleAccessibilityIdentifier: String?
	var infoButtonAccessibilityIdentifier: String?
	
	// MARK: - Private
	private func setupInfections(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Infections.title
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Infections.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Infections.infoButton
		illustrationImage = UIImage(named: "Illu_Bestaetigte_Neuinfektionen")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
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
		subtitle = AppStrings.Statistics.Card.fromCWA
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton
		illustrationImage = UIImage(named: "Illu_Warnende_Personen")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
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
	}

	private func setupIncidence(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Incidence.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Incidence.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Incidence.infoButton
		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.Incidence.today,
				yesterdayString: AppStrings.Statistics.Card.Incidence.yesterday,
				otherDateString: AppStrings.Statistics.Card.Incidence.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.Incidence.secondaryLabelTitle
	}

	private func setupReproductionNumber(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.ReproductionNumber.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton
		illustrationImage = UIImage(named: "Illu_7-Tage-R-Wert")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.ReproductionNumber.today,
				yesterdayString: AppStrings.Statistics.Card.ReproductionNumber.yesterday,
				otherDateString: AppStrings.Statistics.Card.ReproductionNumber.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.ReproductionNumber.secondaryLabelTitle
	}

	private func setupAtLeastOneVaccinatedPerson(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.AtleastOneVaccinated.title
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.infoButton
		illustrationImage = UIImage(named: "AtleastOneVaccinated")
		subtitle = AppStrings.Statistics.Card.fromNationWide

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValueWithPercent
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.AtleastOneVaccinated.today,
				yesterdayString: AppStrings.Statistics.Card.AtleastOneVaccinated.yesterday,
				otherDateString: AppStrings.Statistics.Card.AtleastOneVaccinated.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.AtleastOneVaccinated.primarySubtitle
		
		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.AtleastOneVaccinated.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.AtleastOneVaccinated.tertiaryLabelTitle
		}
	}

	private func setupFullyVaccinatedPeople(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.FullyVaccinated.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.FullyVaccinated.infoButton

		illustrationImage = UIImage(named: "FullyVaccinated")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValueWithPercent
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.FullyVaccinated.today,
				yesterdayString: AppStrings.Statistics.Card.FullyVaccinated.yesterday,
				otherDateString: AppStrings.Statistics.Card.FullyVaccinated.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.FullyVaccinated.primarySubtitle
		
		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.FullyVaccinated.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.FullyVaccinated.tertiaryLabelTitle
		}
	}
	
	private func setupAppliedVaccinationsDoseRates(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.DoseRates.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Doses.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Doses.infoButton
		illustrationImage = UIImage(named: "Doses")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
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
