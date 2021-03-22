////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension Checkin {

	static func mock(
		id: Int = 0,
		traceLocationGUID: String = "",
		traceLocationVersion: Int = 0,
		traceLocationType: TraceLocationType = .type1,
		traceLocationDescription: String = "",
		traceLocationAddress: String = "",
		traceLocationStartDate: Date? = nil,
		traceLocationEndDate: Date? = nil,
		traceLocationDefaultCheckInLengthInMinutes: Int? = nil,
		traceLocationSignature: String = "",
		checkinStartDate: Date = Date(),
		checkinEndDate: Date? = nil,
		targetCheckinEndDate: Date? = nil,
		createJournalEntry: Bool = false
	) -> Self {
		Checkin(
			id: id,
			traceLocationGUID: traceLocationGUID,
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
			targetCheckinEndDate: targetCheckinEndDate,
			createJournalEntry: createJournalEntry
		)
   }

}
