////
// 🦠 Corona-Warn-App
//

import Foundation

enum HomeStatisticsCard: Int32, CaseIterable {
	case infections = 1
	case incidence = 2
	case keySubmissions = 3
	case reproductionNumber = 4
	case atLeastOneVaccinatedPerson = 5
	case completeVaccinatedPeople = 6
	case appliedVaccinationsDoseRates = 7
}
