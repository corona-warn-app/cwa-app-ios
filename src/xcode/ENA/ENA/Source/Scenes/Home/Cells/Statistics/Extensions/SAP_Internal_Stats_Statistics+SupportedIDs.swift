////
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_Stats_Statistics {

	var supportedCardIDSequence: [Int32] {
		cardIDSequence.filter { HomeStatisticsCard.allCases.map { $0.rawValue }.contains($0) }
	}

}
