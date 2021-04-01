////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension Checkin {

	static func mock(
		id: Int = 0,
		traceLocationId: Data = Data(),
		traceLocationIdHash: Data? = nil,
		traceLocationVersion: Int = 0,
		traceLocationType: TraceLocationType = .locationTypeUnspecified,
		traceLocationDescription: String = "traceLocationDescription",
		traceLocationAddress: String = "traceLocationAddress",
		traceLocationStartDate: Date? = nil,
		traceLocationEndDate: Date? = nil,
		traceLocationDefaultCheckInLengthInMinutes: Int? = nil,
		cryptographicSeed: Data = Data(),
		cnPublicKey: Data = Data(),
		checkinStartDate: Date = Date(timeIntervalSinceNow: -7200),
		checkinEndDate: Date = Date(timeIntervalSinceNow: -3600),
		checkinCompleted: Bool = false,
		createJournalEntry: Bool = false
	) -> Self {
		Checkin(
			id: id,
			traceLocationId: traceLocationId,
			traceLocationIdHash: traceLocationIdHash ?? traceLocationId.sha256(),
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
