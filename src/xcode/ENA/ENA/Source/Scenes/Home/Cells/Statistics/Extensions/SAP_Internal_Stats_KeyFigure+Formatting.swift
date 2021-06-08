////
// 🦠 Corona-Warn-App
//

import UIKit

extension SAP_Internal_Stats_KeyFigure {
	func formattedValue(cardRawValue: Int32? = nil) -> String? {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		var formattedString: String?
		
		if value >= 10_000_000 {
			numberFormatter.minimumFractionDigits = 1
			numberFormatter.maximumFractionDigits = 1

			let value = self.value / 1_000_000
			guard let formattedNumber = numberFormatter.string(from: NSNumber(value: value)) else {
				return nil
			}

			formattedString = String(format: AppStrings.Statistics.Card.million, formattedNumber)
		} else {
			let decimals = max(0, Int(self.decimals))
			numberFormatter.minimumFractionDigits = Int(decimals)
			numberFormatter.maximumFractionDigits = Int(decimals)

			formattedString = numberFormatter.string(from: NSNumber(value: value))
		}
		guard let cardId = cardRawValue else {
			return formattedString
		}
		switch HomeStatisticsCard(rawValue: cardId) {
		case .atLeastOneVaccinatedPerson, .fullyVaccinatedPeople:
			guard let valueString = formattedString else {
				return formattedString
			}
			return valueString + AppStrings.Statistics.percent
		case .infections, .incidence, .keySubmissions, .reproductionNumber, .appliedVaccinationsDoseRates:
			return formattedString
		case .none:
			Log.info("Statistics card ID \(cardId) is not supported", log: .ui)
			return formattedString
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
