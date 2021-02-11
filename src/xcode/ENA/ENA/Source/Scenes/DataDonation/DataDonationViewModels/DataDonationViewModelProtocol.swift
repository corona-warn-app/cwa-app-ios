////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/*** this protocol gets used to provide different view model classes for the dataDonationViewController */

protocol DataDonationViewModelProtocol {

	/// use these 3 to definde @published in a prorocol
	var reloadTableView: Bool { get }
	var reloadTableViewPublished: OpenCombine.Published<Bool> { get }
	var reloadTableViewPublisher: OpenCombine.Published<Bool>.Publisher { get }

	var friendlyFederalStateName: String { get }
	var friendlyRegionName: String { get }
	var friendlyAgeName: String { get }
	var dynamicTableViewModel: DynamicTableViewModel { get }

	func save(consentGiven: Bool)
}
