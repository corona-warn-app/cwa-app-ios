//
// 🦠 Corona-Warn-App
//

import Foundation

enum TransmissionRiskLevelSource {
	case symptomsOnset(SymptomsOnset)
	case fixedValue(Int)
}

extension Array where Element == Checkin {

	/// Helper function to convert checkins to required form factor for exposure submission
	///
	/// - Returns: A list of converted checkins
	func preparedForSubmission(
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		transmissionRiskLevelSource: TransmissionRiskLevelSource
	) -> [SAP_Internal_Pt_CheckIn] {

		let css = CheckinSplittingService()
		let transmissionRiskValueMapping = appConfig.presenceTracingParameters.riskCalculationParameters.transmissionRiskValueMapping

		let preparedCheckins = self
			.filter { !$0.checkinSubmitted }
			.compactMap {
				$0.derivingWarningTimeInterval(config: PresenceTracingSubmissionConfiguration(from: appConfig.presenceTracingParameters.submissionParameters))
			}
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

				switch transmissionRiskLevelSource {
				case .symptomsOnset(let symptomsOnset):
					if let ageInDays = Calendar.current.dateComponents([.day], from: checkin.checkinStartDate, to: Date()).day {
						let riskVector = symptomsOnset.transmissionRiskVector
						transmissionRiskLevel = Int(riskVector[safe: ageInDays] ?? 1)
					} else {
						transmissionRiskLevel = 1
					}
				case .fixedValue(let fixedTransmissionRiskLevel):
					transmissionRiskLevel = fixedTransmissionRiskLevel
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

		return preparedCheckins
	}

	/// Helper function to convert checkins to encrypted CheckInProtectedReports.
	///
	/// - Returns: A list of CheckInProtectedReports
	func preparedProtectedReportsForSubmission(
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		transmissionRiskLevelSource: TransmissionRiskLevelSource
	) -> [SAP_Internal_Pt_CheckInProtectedReport] {

		let checkinSplittingService = CheckinSplittingService()
		let transmissionRiskValueMapping = appConfig.presenceTracingParameters.riskCalculationParameters.transmissionRiskValueMapping

		let preparedCheckins = self
			.filter { !$0.checkinSubmitted }
			.compactMap {
				$0.derivingWarningTimeInterval(config: PresenceTracingSubmissionConfiguration(from: appConfig.presenceTracingParameters.submissionParameters))
			}
			// Split checkins per day
			.reduce([Checkin]()) { value, checkin -> [Checkin] in
				var mutableValue = value
				mutableValue.append(contentsOf: checkinSplittingService.split(checkin))
				return mutableValue
			}
			// transform for submission
			.compactMap { checkin -> SAP_Internal_Pt_CheckInProtectedReport? in
				// Determine Transmission Risk Level
				let transmissionRiskLevel: Int

				switch transmissionRiskLevelSource {
				case .symptomsOnset(let symptomsOnset):
					if let ageInDays = Calendar.current.dateComponents([.day], from: checkin.checkinStartDate, to: Date()).day {
						let riskVector = symptomsOnset.transmissionRiskVector
						transmissionRiskLevel = Int(riskVector[safe: ageInDays] ?? 1)
					} else {
						transmissionRiskLevel = 1
					}
				case .fixedValue(let fixedTransmissionRiskLevel):
					transmissionRiskLevel = fixedTransmissionRiskLevel
				}

				// Filter out irrelevant checkins, i.e. ones with a risk value of zero
				guard
					let transmissionRiskValue = transmissionRiskValueMapping.first(where: { $0.transmissionRiskLevel == transmissionRiskLevel })?.transmissionRiskValue,
					transmissionRiskValue > 0
				else {
					return nil
				}

				let checkinProtectedReport = checkin.createCheckinProtectedReport(
					transmissionRiskLevel: transmissionRiskLevel
				)

				return checkinProtectedReport
			}
			// The set of [Protocol Buffer message CheckInProtectedReport] shall shuffled.
			// This is necessary to comply with Apple's requirements for Event Registration.
			.shuffled()

		return preparedCheckins
	}

}
