////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardViewModel {

	// MARK: - Init

	init(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		if let primaryFigure = keyFigureCard.keyFigures.first(where: { $0.rank == .primary }) {
			primaryValue = primaryFigure.formattedValue

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

	@OpenCombine.Published private(set) var secondaryTitle: String?
	@OpenCombine.Published private(set) var secondaryValue: String?
	@OpenCombine.Published private(set) var secondaryTrendImage: UIImage?
	@OpenCombine.Published private(set) var secondaryTrendImageTintColor: UIColor?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityLabel: String?
	@OpenCombine.Published private(set) var secondaryTrendAccessibilityValue: String?

	@OpenCombine.Published private(set) var tertiaryTitle: String?
	@OpenCombine.Published private(set) var tertiaryValue: String?

	@OpenCombine.Published private(set) var footnote: String?

	var titleAccessiblityIdentifier: String?
	
	// MARK: - Private

	private func setupInfections(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Infections.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.Infections		
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
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.KeySubmissions
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

		footnote = AppStrings.Statistics.Card.KeySubmissions.footnote
	}

	private func setupIncidence(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.Incidence.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.Incidence
		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.Incidence.today,
				yesterdayString: AppStrings.Statistics.Card.Incidence.yesterday,
				otherDateString: AppStrings.Statistics.Card.Incidence.date
			)
		}

		secondaryTitle = AppStrings.Statistics.Card.Incidence.secondaryLabelTitle
	}

	private func setupReproductionNumber(for keyFigureCard: SAP_Internal_Stats_KeyFigureCard) {
		title = AppStrings.Statistics.Card.ReproductionNumber.title
		titleAccessiblityIdentifier = AccessibilityIdentifiers.Statistics.ReproductionNumber
		illustrationImage = UIImage(named: "Illu_7-Tage-R-Wert")

		if keyFigureCard.keyFigures.contains(where: { $0.rank == .primary }) {
			let updateDate = Date(timeIntervalSince1970: TimeInterval(keyFigureCard.header.updatedAt))
			primaryTitle = updateDate.formatted(
				todayString: AppStrings.Statistics.Card.ReproductionNumber.today,
				yesterdayString: AppStrings.Statistics.Card.ReproductionNumber.yesterday,
				otherDateString: AppStrings.Statistics.Card.ReproductionNumber.date
			)
		}

		secondaryTitle = AppStrings.Statistics.Card.ReproductionNumber.secondaryLabelTitle
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

private extension SAP_Internal_Stats_KeyFigure {

	var formattedValue: String? {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal

		if value >= 10_000_000 {
			numberFormatter.minimumFractionDigits = 1
			numberFormatter.maximumFractionDigits = 1

			let value = self.value / 1_000_000
			guard let formattedNumber = numberFormatter.string(from: NSNumber(value: value)) else {
				return nil
			}

			return String(format: AppStrings.Statistics.Card.million, formattedNumber)
		} else {
			let decimals = max(0, Int(self.decimals))
			numberFormatter.minimumFractionDigits = Int(decimals)
			numberFormatter.maximumFractionDigits = Int(decimals)

			return numberFormatter.string(from: NSNumber(value: value))
		}
	}

	var trendImage: UIImage? {
		switch trend {
		case .stable:
			return UIImage(named: "Pfeil_stabil_plain")
		case .increasing:
			return UIImage(named: "Pfeil_steigend_plain")
		case .decreasing:
			return UIImage(named: "Pfeil_sinkend_plain")
		case .unspecifiedTrend:
			return nil
		case .UNRECOGNIZED:
			return nil
		}
	}

	var trendTintColor: UIColor? {
		switch trendSemantic {
		case .negative:
			return .enaColor(for: .riskHigh)
		case .neutral:
			return .enaColor(for: .riskNeutral)
		case .positive:
			return .enaColor(for: .riskLow)
		case .unspecifiedTrendSemantic:
			return nil
		case .UNRECOGNIZED:
			return nil
		}
	}

	var trendAccessibilityLabel: String? {
		switch trend {
		case .stable:
			return AppStrings.Statistics.Card.trendStable
		case .increasing:
			return AppStrings.Statistics.Card.trendIncreasing
		case .decreasing:
			return AppStrings.Statistics.Card.trendDecreasing
		case .unspecifiedTrend:
			return nil
		case .UNRECOGNIZED:
			return nil
		}
	}

	var trendAccessibilityValue: String? {
		switch trendSemantic {
		case .negative:
			return AppStrings.Statistics.Card.trendSemanticNegative
		case .neutral:
			return AppStrings.Statistics.Card.trendSemanticNeutral
		case .positive:
			return AppStrings.Statistics.Card.trendSemanticPositive
		case .unspecifiedTrendSemantic:
			return nil
		case .UNRECOGNIZED:
			return nil
		}
	}

}
