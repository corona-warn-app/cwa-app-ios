//
// 🦠 Corona-Warn-App
//

import Foundation

struct AllowListResource: Resource {
	
	// MARK: - Init

	init() {
		self.locator = .validationServiceAllowlist()
		self.type = .caching
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>
	typealias CustomError = Error // no custom error here at the moment
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>
	
	// Tech spec says that the default is an empty set
	var defaultModel: SAP_Internal_Dgc_ValidationServiceAllowlist? {
		return SAP_Internal_Dgc_ValidationServiceAllowlist()
	}
	
	var cachingTypes: Set<CachingType> {
		[CachingType.noNetwork]
		.blubb(statusCodeRange: 400...409)
		.blubb(statusCodeRange: 500...509)
//		return CachingType.blubb(first: [.noNetwork], second: 400...409)
//		[.noNetwork, .statusCode(400)...CachingType.statusCode(409)]
//		return CachingType.statusCodesWithRange(400...409) + .noNetwork
//		[.noNetwork, .statusCodesWithRange(400...409)]
//		var cachingTypes = CachingType.statusCodesWithRange(400...409)
//		cachingTypes.insert(.noNetwork)
//		return cachingTypes
	}
}
