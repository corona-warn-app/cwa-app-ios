//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct TicketValidationAllowList: Codable {
	let validationServiceAllowList: [ValidationServiceAllowlistEntry]
	let serviceProviderAllowList: [Data]
}
