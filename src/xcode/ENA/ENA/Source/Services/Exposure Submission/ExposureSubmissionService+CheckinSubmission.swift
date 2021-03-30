//
// 🦠 Corona-Warn-App
//

import Foundation

extension ExposureSubmissionService {

	/// Helper function to convert checkins to required form factor for exposure submission
	///
	///  Details on the implementation can be found in the [tech spec](https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#attendee-check-in-submission).
	/// - Returns: A list of converted checkins
	func preparedCheckinsForSubmission(with appConfigProvider: AppConfigurationProviding, symptomOnset: SymptomsOnset) -> [SAP_Internal_Pt_CheckIn] {
		let eventStore = EventStore(url: EventStore.storeURL)
		let raw🐓 = eventStore?.checkinsPublisher.value ?? []

		let css = CheckinSplittingService()
		let appConfig = appConfigProvider.syncronousAppConfig()
		let transmissionRiskValueMapping = appConfig.presenceTracingParameters.riskCalculationParameters.transmissionRiskValueMapping

		let checkins = raw🐓
			// Split checkins per day
			.reduce([Checkin]()) { _, checkin -> [Checkin] in
				css.split(checkin)
			}
			// transform for submission
			.compactMap { checkin -> SAP_Internal_Pt_CheckIn? in
				do {
					var transformed = try checkin.prepareForSubmission() as SAP_Internal_Pt_CheckIn
					// Determine Transmission Risk Level
					let transmissionRiskLevel: Int
					if let ageInDays = Calendar.autoupdatingCurrent.dateComponents([.day], from: checkin.checkinStartDate).day {
						let riskVector = symptomOnset.transmissionRiskVector
						transmissionRiskLevel = Int(riskVector[safe: ageInDays] ?? 1)
					} else {
						transmissionRiskLevel = 1
					}

					// Filter out irrelevant checkins, i.e. ones with a risk value of zero
					guard transmissionRiskValueMapping[transmissionRiskLevel].transmissionRiskValue > 0 else {
						return nil
					}

					transformed.transmissionRiskLevel = UInt32(transmissionRiskLevel)
					return transformed
				} catch {
					Log.error("Checkin conversion error", log: .checkin, error: error)
					return nil
				}
			}

		return checkins
	}
}

private extension AppConfigurationProviding {
	func syncronousAppConfig() -> SAP_Internal_V2_ApplicationConfigurationIOS {
		#warning("not implemented - yet")
		return SAP_Internal_V2_ApplicationConfigurationIOS()
	}
}
