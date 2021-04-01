////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension Checkin {


	/// Provide a set of default parameters to quickly generate a `Checkin`
	/// - Returns: A mocked `Checkin`
	static func mock(
		id: Int = 0,
		traceLocationId: Data = Data(),
		traceLocationIdHash: Data? = nil,
		traceLocationVersion: Int = 0,
		traceLocationType: TraceLocationType = .locationTypeUnspecified,
		traceLocationDescription: String = "traceLocationDescription",
		traceLocationAddress: String = "traceLocationAddress",
		traceLocationStartDate: Date = Date(timeIntervalSinceNow: -14400),
		traceLocationEndDate: Date = Date(timeIntervalSinceNow: -1800),
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
