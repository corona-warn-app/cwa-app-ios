//
// 🦠 Corona-Warn-App
//

import Foundation

extension ExposureSubmissionService {

	/// Helper function to convert checkins to required form factor for exposure submission
	///
	///  Details on the implementation can be found in the [tech spec](https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#attendee-check-in-submission).
	/// - Returns: A list of converted checkins
	func preparedCheckinsForSubmission(
		with eventStore: EventStoringProviding,
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		symptomOnset: SymptomsOnset,
		completion: @escaping (_ transformed: [SAP_Internal_Pt_CheckIn]) -> Void
	) {
		let rawCheckins = eventStore.checkinsPublisher.value

		let css = CheckinSplittingService()
		let transmissionRiskValueMapping = appConfig.presenceTracingParameters.riskCalculationParameters.transmissionRiskValueMapping

		let checkins = rawCheckins
			// Split checkins per day
			.reduce([Checkin]()) { value, checkin -> [Checkin] in
				var mutableValue = value
				mutableValue.append(contentsOf: css.split(checkin))
				return mutableValue
			}
			// transform for submission
			.compactMap { checkin -> SAP_Internal_Pt_CheckIn? in
				var preparedCheckin = checkin.prepareForSubmission()
				// Determine Transmission Risk Level
				let transmissionRiskLevel: Int
				if let ageInDays = Calendar.current.dateComponents([.day], from: checkin.checkinStartDate, to: Date()).day {
					let riskVector = symptomOnset.transmissionRiskVector
					transmissionRiskLevel = Int(riskVector[safe: ageInDays] ?? 1)
				} else {
					transmissionRiskLevel = 1
				}

				// Filter out irrelevant checkins, i.e. ones with a risk value of zero
				guard
					let transmissionRiskValue = transmissionRiskValueMapping.first(where: { $0.transmissionRiskLevel == transmissionRiskLevel })?.transmissionRiskValue,
					transmissionRiskValue > 0
				else {
					return nil
				}

				preparedCheckin.transmissionRiskLevel = UInt32(transmissionRiskLevel)
				return preparedCheckin
			}

		completion(checkins)
	}
}
