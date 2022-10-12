////
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_Stats_Statistics {

	var supportedStatisticsCardIDSequence: [Int32] {
		cardIDSequence.filter { HomeStatisticsCard.allCases.map { $0.rawValue }.contains($0) }
	}
	
	var supportedLinkCardIDSequence: [Int32] {
		cardIDSequence.filter { HomeLinkCard.allCases.map { $0.rawValue }.contains($0) }
	}
}
