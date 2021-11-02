////
// 🦠 Corona-Warn-App
//

import Foundation

enum HomeStatisticsCard: Int32, CaseIterable {
	case infections = 1
	case keySubmissions = 3
	case reproductionNumber = 4
	case atLeastOneVaccinatedPerson = 5
	case fullyVaccinatedPeople = 6
	case appliedVaccinationsDoseRates = 7
	case infectedPeopleInIntensiveCare = 9
	case combinedSevenDayAndHospitalization = 10
}
