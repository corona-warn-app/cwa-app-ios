//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationAllowList: Codable {
	let validationServiceAllowList: [ValidationServiceAllowlistEntry]
	let serviceProviderAllowList: [Data]
}
