////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardViewModel {

	// MARK: - Init

	init(for card: Card) {
		switch card {
		case .newInfections:
			setupNewInfections()
		case .warningPersons:
			setupWarningPersons()
		case .incidence:
			setupIncidence()
		case .rValue:
			setupRValue()
		}
	}

	// MARK: - Internal

	enum Card: Int {
		case newInfections
		case warningPersons
		case incidence
		case rValue
	}

	@OpenCombine.Published var title: String?

	@OpenCombine.Published var illustrationImage: UIImage?

	@OpenCombine.Published var primaryTitle: String?
	@OpenCombine.Published var primaryValue: String?
	@OpenCombine.Published var primaryTrendImage: UIImage?

	@OpenCombine.Published var secondaryTitle: String?
	@OpenCombine.Published var secondaryValue: String?
	@OpenCombine.Published var secondaryTrendImage: UIImage?

	@OpenCombine.Published var tertiaryTitle: String?
	@OpenCombine.Published var tertiaryValue: String?

	@OpenCombine.Published var footnote: String?

	// MARK: - Private

	private func setupNewInfections() {
		title = AppStrings.Statistics.Card.NewInfections.title
		illustrationImage = UIImage(named: "Illu_Bestaetigte_Neuinfektionen")
		primaryTitle = AppStrings.Statistics.Card.NewInfections.primaryLabelTitle
		primaryValue = "14.714"
		primaryTrendImage = nil
		secondaryTitle = AppStrings.Statistics.Card.NewInfections.secondaryLabelTitle
		secondaryValue = "11.981"
		secondaryTrendImage = UIImage(named: "Pfeil_steigend")
		tertiaryTitle = AppStrings.Statistics.Card.NewInfections.tertiaryLabelTitle
		tertiaryValue = "429.181"
		footnote = nil
	}

	private func setupWarningPersons() {
		title = AppStrings.Statistics.Card.WarningPersons.title
		illustrationImage = UIImage(named: "Illu_Warnende_Personen")
		primaryTitle = AppStrings.Statistics.Card.WarningPersons.primaryLabelTitle
		primaryValue = "1.514"
		primaryTrendImage = nil
		secondaryTitle = AppStrings.Statistics.Card.WarningPersons.secondaryLabelTitle
		secondaryValue = "1.812"
		secondaryTrendImage = UIImage(named: "Pfeil_sinkend")
		tertiaryTitle = AppStrings.Statistics.Card.WarningPersons.tertiaryLabelTitle
		tertiaryValue = "20.922"
		footnote = AppStrings.Statistics.Card.WarningPersons.footnote
	}

	private func setupIncidence() {
		title = AppStrings.Statistics.Card.Incidence.title
		illustrationImage = UIImage(named: "Illu_7-Tage-Inzidenz")
		primaryTitle = AppStrings.Statistics.Card.Incidence.primaryLabelTitle
		primaryValue = "98,9"
		primaryTrendImage = UIImage(named: "Pfeil_steigend")
		secondaryTitle = AppStrings.Statistics.Card.Incidence.secondaryLabelTitle
		secondaryValue = nil
		secondaryTrendImage = nil
		tertiaryTitle = nil
		tertiaryValue = nil
		footnote = nil
	}

	private func setupRValue() {
		title = AppStrings.Statistics.Card.RValue.title
		illustrationImage = UIImage(named: "Illu_7-Tage-R-Wert")
		primaryTitle = AppStrings.Statistics.Card.RValue.primaryLabelTitle
		primaryValue = "1,04"
		primaryTrendImage = UIImage(named: "Pfeil_steigend")
		secondaryTitle = AppStrings.Statistics.Card.RValue.secondaryLabelTitle
		secondaryValue = nil
		secondaryTrendImage = nil
		tertiaryTitle = nil
		tertiaryValue = nil
		footnote = nil
	}

}
