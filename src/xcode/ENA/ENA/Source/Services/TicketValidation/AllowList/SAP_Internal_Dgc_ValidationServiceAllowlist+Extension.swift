//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

extension SAP_Internal_Dgc_ValidationServiceAllowlist {
	var allowlist: TicketValidationAllowList {
		let validationServiceAllowList = certificates.map({
			ValidationServiceAllowlistEntry(
				serviceProvider: $0.serviceProvider,
				hostname: $0.hostname,
				fingerprint256: $0.fingerprint256.base64EncodedString()
			)
		})
		let serviceProviderAllowList = serviceProviders.map({
			$0.serviceIdentityHash
		})
		return TicketValidationAllowList(
			validationServiceAllowList: validationServiceAllowList,
			serviceProviderAllowList: serviceProviderAllowList
		)
	}
}
