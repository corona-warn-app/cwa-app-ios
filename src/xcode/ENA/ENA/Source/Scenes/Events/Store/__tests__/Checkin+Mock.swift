////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension Checkin {

	static func mock(
		id: Int = 0,
		traceLocationGUID: String = "",
		traceLocationGUIDHash: Data = Data(),
		traceLocationVersion: Int = 0,
		traceLocationType: TraceLocationType = .locationTypeUnspecified,
		traceLocationDescription: String = "",
		traceLocationAddress: String = "",
		traceLocationStartDate: Date? = nil,
		traceLocationEndDate: Date? = nil,
		traceLocationDefaultCheckInLengthInMinutes: Int? = nil,
		traceLocationSignature: String = "",
		checkinStartDate: Date = Date(),
		checkinEndDate: Date = Date(),
		checkinCompleted: Bool = false,
		createJournalEntry: Bool = false
	) -> Self {
		Checkin(
			id: id,
			traceLocationGUID: traceLocationGUID,
			traceLocationGUIDHash: traceLocationGUIDHash,
			traceLocationVersion: traceLocationVersion,
			traceLocationType: traceLocationType,
			traceLocationDescription: traceLocationDescription,
			traceLocationAddress: traceLocationAddress,
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: traceLocationSignature,
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: checkinCompleted,
			createJournalEntry: createJournalEntry
		)
   }

}
