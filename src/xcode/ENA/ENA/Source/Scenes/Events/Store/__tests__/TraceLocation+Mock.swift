////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TraceLocation {

	static func mock(
		guid: String = "",
		version: Int = 0,
		type: TraceLocationType = .locationTypeUnspecified,
		description: String = "",
		address: String = "",
		startDate: Date? = nil,
		endDate: Date? = nil,
		defaultCheckInLengthInMinutes: Int? = nil,
		byteRepresentation: Data = Data(),
		signature: String = ""
	) -> Self {
		TraceLocation(
			guid: guid,
			version: version,
			type: type,
			description: description,
			address: address,
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
			byteRepresentation: byteRepresentation,
			signature: signature
		)
   }

}
