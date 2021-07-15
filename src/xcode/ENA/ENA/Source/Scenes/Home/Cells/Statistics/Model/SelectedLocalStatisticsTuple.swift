//
// 🦠 Corona-Warn-App
//

struct SelectedLocalStatisticsTuple {
	
	// MARK: - Init

	init(
		localStatisticsData: [SAP_Internal_Stats_AdministrativeUnitData],
		localStatisticsDistrict: LocalStatisticsDistrict
	) {
		self.localStatisticsData = localStatisticsData
		self.localStatisticsDistrict = localStatisticsDistrict
	}
	
	// MARK: - Internal

	var localStatisticsData: [SAP_Internal_Stats_AdministrativeUnitData]
	var localStatisticsDistrict: LocalStatisticsDistrict
}
