//
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == SAP_Internal_RiskScoreClass {
	private func firstWhereLabel(is label: String) -> SAP_Internal_RiskScoreClass? {
		first(where: { $0.label == label })
	}
	var low: SAP_Internal_RiskScoreClass? { firstWhereLabel(is: "LOW") }
	var high: SAP_Internal_RiskScoreClass? { firstWhereLabel(is: "HIGH") }
}
