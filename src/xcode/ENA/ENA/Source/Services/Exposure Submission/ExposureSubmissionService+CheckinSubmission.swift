//
// 🦠 Corona-Warn-App
//

import Foundation

extension ExposureSubmissionService {

	/// Helper function to convert checkins to required form factor for exposure submission
	///
	///  Details on the implementation, especially the risk calculation can be found in the [tech spec](https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#risk-calculation).
	/// - Returns: A list of converted checkins
	func preparedCheckinsForSubmission(with appConfig: AppConfigurationProviding) -> [SAP_Internal_Pt_CheckIn] {
		let eventStore = EventStore(url: EventStore.storeURL)
		let raw🐓 = eventStore?.checkinsPublisher.value ?? []

		let css = CheckinSplittingService()
		let matches = eventStore?.traceTimeIntervalMatchesPublisher.value ?? []
		let warnings = eventStore?.traceWarningPackageMetadatasPublisher.value ?? []

		let appConfig = appConfig.syncronousAppConfig()
		let transmissionRiskValueMapping = appConfig.presenceTracingParameters.riskCalculationParameters.transmissionRiskValueMapping

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
					var transformed = try checkin.prepareForSubmission()
					// let riskValue = transmissionRiskValueMapping.first(where: { $0.transmissionRiskLevel == })
					// transformed.transmissionRiskLevel = 42
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
