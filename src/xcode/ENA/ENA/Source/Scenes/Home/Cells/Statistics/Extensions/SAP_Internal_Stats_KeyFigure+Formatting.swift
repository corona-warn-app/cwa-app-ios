////
// 🦠 Corona-Warn-App
//

import UIKit

extension SAP_Internal_Stats_KeyFigure {
	var formattedValue: String? {
		let decimals = max(0, Int(self.decimals))
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		numberFormatter.minimumFractionDigits = Int(decimals)
		numberFormatter.maximumFractionDigits = Int(decimals)
		return numberFormatter.string(from: NSNumber(value: value))
	}

	var formattedValueWithPercent: String? {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .percent
		let decimals = max(0, Int(self.decimals))
		numberFormatter.maximumFractionDigits = Int(decimals)
		return numberFormatter.string(from: NSNumber(value: value / 100))?.filter({ !$0.isWhitespace })
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
