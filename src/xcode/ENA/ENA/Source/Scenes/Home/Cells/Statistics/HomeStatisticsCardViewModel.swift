////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardViewModel {

	// MARK: - Init

	init(for card: Card) {
		switch card {
		case .infections:
			setupInfections()
		case .incidence:
			setupIncidence()
		case .keySubmissions:
			setupKeySubmissions()
		case .reproductionNumber:
			setupReproductionNumber()
		}
	}

	// MARK: - Internal

	enum Card: Int {
		case infections = 1
		case incidence = 2
		case keySubmissions = 3
		case reproductionNumber = 4
	}

	@OpenCombine.Published var title: String?

	@OpenCombine.Published var illustrationImage: UIImage!

	@OpenCombine.Published var primaryTitle: String?
	@OpenCombine.Published var primaryValue: String?
	@OpenCombine.Published var primaryTrendImage: UIImage?
	@OpenCombine.Published var primaryTrendAccessibilityLabel: String?

	@OpenCombine.Published var secondaryTitle: String?
	@OpenCombine.Published var secondaryValue: String?
	@OpenCombine.Published var secondaryTrendImage: UIImage?
	@OpenCombine.Published var secondaryTrendAccessibilityLabel: String?

	@OpenCombine.Published var tertiaryTitle: String?
	@OpenCombine.Published var tertiaryValue: String?

	@OpenCombine.Published var footnote: String?

	// MARK: - Private

	private func setupInfections() {
		title = AppStrings.Statistics.Card.Infections.title

		illustrationImage = UIImage(named: "Illu_Bestaetigte_Neuinfektionen")

		primaryTitle = AppStrings.Statistics.Card.Infections.primaryLabelTitle
		primaryValue = "14.714"
		primaryTrendImage = nil
		primaryTrendAccessibilityLabel = nil

		secondaryTitle = AppStrings.Statistics.Card.Infections.secondaryLabelTitle
		secondaryValue = "11.981"
		secondaryTrendImage = UIImage(named: "Pfeil_steigend")
		secondaryTrendAccessibilityLabel = AppStrings.Statistics.Card.trendIncreasing

		tertiaryTitle = AppStrings.Statistics.Card.Infections.tertiaryLabelTitle
		tertiaryValue = "429.181"

		footnote = nil
	}

	private func setupKeySubmissions() {
		title = AppStrings.Statistics.Card.KeySubmissions.title

		illustrationImage = UIImage(named: "Illu_Warnende_Personen")

		primaryTitle = AppStrings.Statistics.Card.KeySubmissions.primaryLabelTitle
		primaryValue = "1.514"
		primaryTrendImage = nil
		primaryTrendAccessibilityLabel = nil

		secondaryTitle = AppStrings.Statistics.Card.KeySubmissions.secondaryLabelTitle
		secondaryValue = "1.812"
		secondaryTrendImage = UIImage(named: "Pfeil_stabil")
		secondaryTrendAccessibilityLabel = AppStrings.Statistics.Card.trendStable

		tertiaryTitle = AppStrings.Statistics.Card.KeySubmissions.tertiaryLabelTitle
		tertiaryValue = "20.922"

		footnote = AppStrings.Statistics.Card.KeySubmissions.footnote
	}

	private func setupIncidence() {
		title = AppStrings.Statistics.Card.Incidence.title

		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")

		primaryTitle = AppStrings.Statistics.Card.Incidence.primaryLabelTitle
		primaryValue = "98,9"
		primaryTrendImage = UIImage(named: "Pfeil_steigend")
		primaryTrendAccessibilityLabel = AppStrings.Statistics.Card.trendIncreasing

		secondaryTitle = AppStrings.Statistics.Card.Incidence.secondaryLabelTitle
		secondaryValue = nil
		secondaryTrendImage = nil
		secondaryTrendAccessibilityLabel = nil

		tertiaryTitle = nil
		tertiaryValue = nil

		footnote = nil
	}

	private func setupReproductionNumber() {
		title = AppStrings.Statistics.Card.ReproductionNumber.title

		illustrationImage = UIImage(named: "Illu_7-Tage-R-Wert")

		primaryTitle = AppStrings.Statistics.Card.ReproductionNumber.primaryLabelTitle
		primaryValue = "1,04"
		primaryTrendImage = UIImage(named: "Pfeil_sinkend")
		primaryTrendAccessibilityLabel = AppStrings.Statistics.Card.trendDecreasing

		secondaryTitle = AppStrings.Statistics.Card.ReproductionNumber.secondaryLabelTitle
		secondaryValue = nil
		secondaryTrendImage = nil
		secondaryTrendAccessibilityLabel = nil

		tertiaryTitle = nil
		tertiaryValue = nil

		footnote = nil
	}

}
