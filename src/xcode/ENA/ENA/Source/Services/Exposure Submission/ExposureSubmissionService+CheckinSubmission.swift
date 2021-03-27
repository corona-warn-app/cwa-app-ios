//
// 🦠 Corona-Warn-App
//

import Foundation

extension ExposureSubmissionService {
	func preparedCheckinsForSubmission() -> [SAP_Internal_Pt_CheckIn] {
		let eventStore = EventStore(url: EventStore.storeURL)
		let raw🐓 = eventStore?.checkinsPublisher.value ?? []

		let css = CheckinSplittingService()
		let matches = eventStore?.traceTimeIntervalMatchesPublisher.value ?? []
		let warnings = eventStore?.traceWarningPackageMetadatasPublisher.value ?? []

		let checkins = raw🐓
			// Split checkins per day
			.reduce([Checkin]()) { _, checkin -> [Checkin] in
				css.split(checkin)
			}
			// calculate overlap
			.map { checkin -> Checkin in
				var checkin = checkin
				checkin.updateOverlap(with: matches)
				return checkin
			}
			// transform for submission
			.compactMap { checkin -> SAP_Internal_Pt_CheckIn? in
				do {
					return try checkin.prepareForSubmission()
				} catch {
					Log.error("Checkin conversion error", log: .checkin, error: error)
					return nil
				}
			}

		return checkins
	}
}
