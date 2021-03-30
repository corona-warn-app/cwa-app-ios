////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

import Foundation

class CheckinSplittingService {

	// MARK: - Internal

	// Algorithm from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/a053f23d4d33721ac98f70ccc05175fbcfc35632/sample-code/presence-tracing/pt-split-check-in-by-midnight-utc.js

	func split(_ checkin: Checkin) -> [Checkin] {
		let endTimeInterval = checkin.checkinEndDate.timeIntervalSince1970
		let startTimeInterval = checkin.checkinStartDate.timeIntervalSince1970

		guard endTimeInterval >= startTimeInterval else {
			return [Checkin]()
		}

		let durationInDays = Int(ceil((endTimeInterval - intervalToMidnightUTC(from: startTimeInterval)) / 86400))

		func isFirst(_ index: Int) -> Bool {
			index == 0
		}

		func isLast(_ index: Int) -> Bool {
			index == durationInDays - 1
		}

		var checkins = [Checkin]()
		(0..<durationInDays).forEach { index in
			if isFirst(index) && !isLast(index) {
				let startDate = checkin.checkinStartDate
				let endDate = Date(timeIntervalSince1970: intervalToMidnightUTC(from: checkin.checkinStartDate.timeIntervalSince1970) + nDaysInterval(index + 1))
				checkins.append(checkin.updatedWith(startDate: startDate, endDate: endDate))
			} else if !isFirst(index) && isLast(index) {
				let startDate = Date(timeIntervalSince1970: intervalToMidnightUTC(from: checkin.checkinEndDate.timeIntervalSince1970))
				let endDate = checkin.checkinEndDate
				checkins.append(checkin.updatedWith(startDate: startDate, endDate: endDate))
			} else if !isFirst(index) && !isLast(index) {
				let startDate = Date(timeIntervalSince1970: intervalToMidnightUTC(from: startTimeInterval) + nDaysInterval(index))
				let endDate = Date(timeIntervalSince1970: intervalToMidnightUTC(from: startTimeInterval) + nDaysInterval(index + 1))
				checkins.append(checkin.updatedWith(startDate: startDate, endDate: endDate))
			} else {
				checkins.append(checkin)
			}
		}

		return checkins
	}

	// MARK: - Private

	private func intervalToMidnightUTC(from timeInterval: TimeInterval) -> TimeInterval {
		Double(Int(timeInterval / 86400) * 86400)
	}

	private func nDaysInterval(_ days: Int) -> TimeInterval {
		Double(days * 86400)
	}
}

private extension Checkin {

	func updatedWith(startDate: Date, endDate: Date) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationId: self.traceLocationId,
			traceLocationIdHash: self.traceLocationIdHash,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: self.cryptographicSeed,
			cnPublicKey: self.cnPublicKey,
			checkinStartDate: startDate ?? self.checkinStartDate,
			checkinEndDate: endDate ?? self.checkinEndDate,
			checkinCompleted: self.checkinCompleted,
			createJournalEntry: self.createJournalEntry
		)
	}
}
