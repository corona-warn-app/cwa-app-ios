////
// 🦠 Corona-Warn-App
//

import Foundation

struct RegionStatisticsData {

	// MARK: - Init

	init(
		region: LocalStatisticsRegion,
		updatedAt: Int64? = nil,
		sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData? = nil,
		sevenDayHospitalizationIncidenceUpdatedAt: Int64? = nil,
		sevenDayHospitalizationIncidence: SAP_Internal_Stats_SevenDayIncidenceData? = nil
	) {
		self.region = region
		self.updatedAt = updatedAt
		self.sevenDayIncidence = sevenDayIncidence
		self.sevenDayHospitalizationIncidenceUpdatedAt = sevenDayHospitalizationIncidenceUpdatedAt
		self.sevenDayHospitalizationIncidence = sevenDayHospitalizationIncidence
	}

	init(
		region: LocalStatisticsRegion,
		localStatisticsData: [SAP_Internal_Stats_LocalStatistics]
	) {
		self.region = region

		switch region.regionType {
		case .federalState:
			let federalStateData = localStatisticsData
				.flatMap { $0.federalStateData }
				.first {
					$0.federalState.rawValue == Int(region.id)
				}

			updatedAt = federalStateData?.updatedAt
			sevenDayIncidence = federalStateData?.sevenDayIncidence
			sevenDayHospitalizationIncidenceUpdatedAt = federalStateData?.sevenDayHospitalizationIncidenceUpdatedAt
			sevenDayHospitalizationIncidence = federalStateData?.sevenDayHospitalizationIncidence
		case .administrativeUnit:
			let administrativeUnitData = localStatisticsData
				.flatMap { $0.administrativeUnitData }
				.first {
					$0.administrativeUnitShortID == Int(region.id) ?? 0
				}
			let federalStateData = localStatisticsData
				.flatMap { $0.federalStateData }
				.first {
					$0.federalState.rawValue == region.federalState.federalStateProtobufId
				}
			
			updatedAt = administrativeUnitData?.updatedAt
			sevenDayIncidence = administrativeUnitData?.sevenDayIncidence
			// we use data from respective federal state for hospitalization incidences in case of administrative unit
			sevenDayHospitalizationIncidenceUpdatedAt = federalStateData?.sevenDayHospitalizationIncidenceUpdatedAt
			sevenDayHospitalizationIncidence = federalStateData?.sevenDayHospitalizationIncidence
		}
	}

	// MARK: - Internal

	var region: LocalStatisticsRegion
	var updatedAt: Int64?
	var sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData?
	var sevenDayHospitalizationIncidenceUpdatedAt: Int64?
	var sevenDayHospitalizationIncidence: SAP_Internal_Stats_SevenDayIncidenceData?
}
