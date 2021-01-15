////
// 🦠 Corona-Warn-App
//

import Foundation

protocol StatisticsCaching: AnyObject {
	var statistics: StatisticsFetchingResponse? { get set }
}
