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
		case .infectedPeopleInIntensiveCare:
			setupInfectedPeopleInIntensiveCare(for: keyFigureCard)
		case .combinedSevenDayAndHospitalization:
			setupCombinedSevenDayAndHospitalization(for: keyFigureCard)
		case .boosterVaccination:
			setupBoosterVaccination(for: keyFigureCard)
		case .none:
			Log.info("Statistics card ID \(keyFigureCard.header.cardID) is not supported", log: .ui)
		}
	}
	
	init(regionStatisticsData: RegionStatisticsData) {
		title = AppStrings.Statistics.AddCard.localCardTitle
		titleAccessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.localStatisticsCardTitle
		subtitle = regionStatisticsData.region.localizedName
		illustrationImage = UIImage(named: "Illu_7-Tage-Lokal-Inzidenz")

		if let sevenDayTrend = regionStatisticsData.sevenDayIncidence, let updatedAt = regionStatisticsData.updatedAt {
			primaryValue = sevenDayTrend.formattedValue
			primaryTrendImage = sevenDayTrend.trendImage
			primaryTrendImageTintColor = sevenDayTrend.trendTintColor
			primaryTrendAccessibilityLabel = sevenDayTrend.trendAccessibilityLabel
			primaryTrendAccessibilityValue = sevenDayTrend.trendAccessibilityValue

			let updateDate = Date(timeIntervalSince1970: TimeInterval(updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.Region.today,
				yesterdayString: AppStrings.Statistics.Card.Region.yesterday,
				otherDateString: AppStrings.Statistics.Card.Region.date
			)
		} else {
			primaryTitle = String(format: AppStrings.Statistics.Card.Region.date, "")
		}
		primarySubtitle = AppStrings.Statistics.Card.Region.primaryLabelSubtitle
		
		if let sevenDayHospitalizationTrend = regionStatisticsData.sevenDayHospitalizationIncidence, let sevenDayHospitalizationIncidenceUpdatedAt = regionStatisticsData.sevenDayHospitalizationIncidenceUpdatedAt {
			secondaryValue = sevenDayHospitalizationTrend.formattedValue
			secondaryTrendImage = sevenDayHospitalizationTrend.trendImage
			secondaryTrendImageTintColor = sevenDayHospitalizationTrend.trendTintColor
			secondaryTrendAccessibilityLabel = sevenDayHospitalizationTrend.trendAccessibilityLabel
			secondaryTrendAccessibilityValue = sevenDayHospitalizationTrend.trendAccessibilityValue

			let sevenDayHospitalizationIncidenceUpdatedDate = Date(timeIntervalSince1970: TimeInterval(sevenDayHospitalizationIncidenceUpdatedAt))
			secondaryTitle = sevenDayHospitalizationIncidenceUpdatedDate.formatted(
				todayString: AppStrings.Statistics.Card.Region.today,
				yesterdayString: AppStrings.Statistics.Card.Region.yesterday,
				otherDateString: AppStrings.Statistics.Card.Region.date
			)
		} else {
			secondaryTitle = String(format: AppStrings.Statistics.Card.Region.date, "")
		}

		if let federalStateName = regionStatisticsData.federalStateName {
			secondarySubtitle = String(format: AppStrings.Statistics.Card.Region.secondaryLabelSubtitleAdministrativeUnit, federalStateName)
		} else {
			secondarySubtitle = AppStrings.Statistics.Card.Region.secondaryLabelSubtitleFederalState
		}
		secondaryValueFontStyle = .title1
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
	@OpenCombine.Published private(set) var secondaryValueFontStyle: ENALabel.Style?
	@OpenCombine.Published private(set) var secondarySubtitle: String?
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
		
	private func setupInfectedPeopleInIntensiveCare(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.IntensiveCare.title
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.IntensiveCare.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.IntensiveCare.infoButton
		illustrationImage = UIImage(named: "Illu_Intensive_Care")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValueWithPercent
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.IntensiveCare.today,
				yesterdayString: AppStrings.Statistics.Card.IntensiveCare.yesterday,
				otherDateString: AppStrings.Statistics.Card.IntensiveCare.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.IntensiveCare.secondaryLabelTitle
	}
	
	private func setupCombinedSevenDayAndHospitalization(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Combined7DaysIncidence.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Combined7DayIncidence.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.Combined7DayIncidence.infoButton

		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue
			let primaryUpdateDate = Date(timeIntervalSince1970: TimeInterval(primaryFigure.updatedAt))
			primaryTitle = primaryUpdateDate.formatted(
				todayString: AppStrings.Statistics.Card.Combined7DaysIncidence.today,
				yesterdayString: AppStrings.Statistics.Card.Combined7DaysIncidence.yesterday,
				otherDateString: AppStrings.Statistics.Card.Combined7DaysIncidence.date
			)
			primarySubtitle = AppStrings.Statistics.Card.Combined7DaysIncidence.primaryLabelSubtitle
		}
		
		if let secondaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .secondary }) {
			secondaryValue = secondaryFigure.formattedValue
			let secondaryUpdateDate = Date(timeIntervalSince1970: TimeInterval(secondaryFigure.updatedAt))
			secondaryTitle = secondaryUpdateDate.formatted(
				todayString: AppStrings.Statistics.Card.Combined7DaysIncidence.today,
				yesterdayString: AppStrings.Statistics.Card.Combined7DaysIncidence.yesterday,
				otherDateString: AppStrings.Statistics.Card.Combined7DaysIncidence.date
			)
			secondarySubtitle = AppStrings.Statistics.Card.Combined7DaysIncidence.secondaryLabelSubtitle
			secondaryValueFontStyle = .title1
		}
	}
	
	private func setupBoosterVaccination(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.BoosterVaccination.title
		subtitle = AppStrings.Statistics.Card.fromNationWide
		titleAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.BoosterVaccination.title
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.Statistics.BoosterVaccination.infoButton

		illustrationImage = UIImage(named: "Illu_Booster_Vaccination")

		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValueWithPercent
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.BoosterVaccination.today,
				yesterdayString: AppStrings.Statistics.Card.BoosterVaccination.yesterday,
				otherDateString: AppStrings.Statistics.Card.BoosterVaccination.date
			)
		}
		primarySubtitle = AppStrings.Statistics.Card.BoosterVaccination.primarySubtitle
		
		if keyFigureCard.keyFigures.contains(where: { $0.rank == .secondary }) {
			secondaryTitle = AppStrings.Statistics.Card.BoosterVaccination.secondaryLabelTitle
		}

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .tertiary }) {
			tertiaryTitle = AppStrings.Statistics.Card.BoosterVaccination.tertiaryLabelTitle
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
