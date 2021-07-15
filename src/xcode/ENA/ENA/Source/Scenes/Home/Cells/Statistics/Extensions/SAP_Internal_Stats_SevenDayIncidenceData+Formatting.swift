//
// 🦠 Corona-Warn-App
//

import UIKit

extension SAP_Internal_Stats_SevenDayIncidenceData {
	
	var formattedValue: String? {
		let decimals = max(0, 1)
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		numberFormatter.minimumFractionDigits = Int(decimals)
		numberFormatter.maximumFractionDigits = Int(decimals)
		return numberFormatter.string(from: NSNumber(value: value))
	}

	var trendImage: UIImage? {
		switch trend {
		case .stable:
			return UIImage(named: "Pfeil_stabil_plain")
		case .increasing:
			return UIImage(named: "Pfeil_steigend_plain")
		case .decreasing:
			return UIImage(named: "Pfeil_sinkend_plain")
		default:
			return nil
		}
	}

	var trendTintColor: UIColor? {
		switch trend {
		case .increasing:
			return .enaColor(for: .riskHigh)
		case .stable:
			return .enaColor(for: .riskNeutral)
		case .decreasing:
			return .enaColor(for: .riskLow)
		default:
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
		default:
			return nil
		}
	}
	
	var trendAccessibilityValue: String? {
		switch trend {
		case .increasing:
			return AppStrings.Statistics.Card.trendSemanticNegative
		case .stable:
			return AppStrings.Statistics.Card.trendSemanticNeutral
		case .decreasing:
			return AppStrings.Statistics.Card.trendSemanticPositive
		default:
			return nil
		}
	}
}
