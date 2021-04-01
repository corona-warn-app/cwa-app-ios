////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension Checkin {

	static func mock(
		id: Int = 0,
		traceLocationId: Data = Data(),
		traceLocationIdHash: Data = Data(),
		traceLocationVersion: Int = 0,
		traceLocationType: TraceLocationType = .locationTypeUnspecified,
		traceLocationDescription: String = "",
		traceLocationAddress: String = "",
		traceLocationStartDate: Date? = nil,
		traceLocationEndDate: Date? = nil,
		traceLocationDefaultCheckInLengthInMinutes: Int? = nil,
		cryptographicSeed: Data = Data(),
		cnPublicKey: Data = Data(),
		checkinStartDate: Date = Date(),
		checkinEndDate: Date = Date(),
		checkinCompleted: Bool = false,
		createJournalEntry: Bool = false
	) -> Self {
		Checkin(
			id: id,
			traceLocationId: traceLocationId,
			traceLocationIdHash: traceLocationIdHash,
			traceLocationVersion: traceLocationVersion,
			traceLocationType: traceLocationType,
			traceLocationDescription: traceLocationDescription,
			traceLocationAddress: traceLocationAddress,
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey,
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: checkinCompleted,
			createJournalEntry: createJournalEntry
		)
   }

}
