////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TraceLocation {

	static func mock(
		id: Data = Data(),
		version: Int = 0,
		type: TraceLocationType = .locationTypeUnspecified,
		description: String = "",
		address: String = "",
		startDate: Date? = nil,
		endDate: Date? = nil,
		defaultCheckInLengthInMinutes: Int? = nil,
		cryptographicSeed: Data = Data(),
		cnMainPublicKey: Data = Data()
	) -> Self {
		TraceLocation(
			id: id,
			version: version,
			type: type,
			description: description,
			address: address,
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
			cryptographicSeed: cryptographicSeed,
			cnMainPublicKey: cnMainPublicKey
		)
   }

}
