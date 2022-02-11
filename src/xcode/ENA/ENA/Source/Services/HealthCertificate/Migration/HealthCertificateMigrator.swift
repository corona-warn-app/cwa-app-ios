//
// 🦠 Corona-Warn-App
//

import Foundation

protocol HealthCertificateMigration {
	func migrate(store: HealthCertificateStoring)
}

class HealthCertificateMigrator: HealthCertificateMigration {
	
	func migrate(store: HealthCertificateStoring) {
		
		let lastVersion = store.healthCertifiedPersonsVersion ?? 0
		guard lastVersion < kCurrentHealthCertifiedPersonsVersion else {
			Log.debug("Migration was done already - stop here")
			return
		}
		defer {
			// after leaving mark migration as done
			store.healthCertifiedPersonsVersion = kCurrentHealthCertifiedPersonsVersion
		}
		
		var newHealthCertifiedPersons = regroup(store.healthCertifiedPersons, iteration: 0)
		newHealthCertifiedPersons.sort()
		for person in newHealthCertifiedPersons {
			person.healthCertificates = person.healthCertificates.sorted(by: <)
		}
		store.healthCertifiedPersons = newHealthCertifiedPersons
	}
	
	private func regroup(_ originalPersons: [HealthCertifiedPerson], iteration: Int) -> [HealthCertifiedPerson] {
		var persons = originalPersons
		guard let firstPerson = persons.first else {
			return []
		}
		persons.removeFirst()
		var matchingPersons = [HealthCertifiedPerson]()
		
		for person in persons {
			for certificate in person.healthCertificates {
				for referenceCertificate in firstPerson.healthCertificates {
					if referenceCertificate.belongsToSamePerson(certificate) {
						matchingPersons.append(person)
					}
				}
			}
		}
		
		if iteration == originalPersons.count {
			persons.append(firstPerson)
			return persons
		}

		if matchingPersons.isEmpty {
			persons.append(firstPerson)
			return regroup(persons, iteration: iteration + 1)
		} else {
			for matchingPerson in matchingPersons {
				firstPerson.healthCertificates += matchingPerson.healthCertificates
				if matchingPerson.isPreferredPerson {
					firstPerson.isPreferredPerson = true
				}
				persons.remove(matchingPerson)
			}
			persons.append(firstPerson)
			
			return regroup(persons, iteration: 0)
		}
	}
	
}
