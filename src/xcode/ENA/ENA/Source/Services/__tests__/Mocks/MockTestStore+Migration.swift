//
// 🦠 Corona-Warn-App
//

extension MockTestStore {
	// set healthCertifiedPersonsVersion to test migration of healthCertifiedPersons
	convenience init(healthCertifiedPersonsVersion: Int?) {
		self.init()
		self.healthCertifiedPersonsVersion = healthCertifiedPersonsVersion
	}
}
