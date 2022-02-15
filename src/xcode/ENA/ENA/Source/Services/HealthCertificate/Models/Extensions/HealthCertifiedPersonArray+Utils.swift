//
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == HealthCertifiedPerson {
	
	func findPersons(
		for certificate: HealthCertificate
	) -> [HealthCertifiedPerson] {
	
		var foundPersons = [HealthCertifiedPerson]()

		for person in self {
			for personCertificate in person.healthCertificates {
				if certificate.belongsToSamePerson(personCertificate) {
					foundPersons.append(person)
				}
			}
		}
		
		return foundPersons
	}
}
