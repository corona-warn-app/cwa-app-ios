//
// 🦠 Corona-Warn-App
//

import Foundation

protocol HealthCertificateMigration {
	func migrate(persons: [HealthCertifiedPerson]) -> [HealthCertifiedPerson]
}

class HealthCertificateMigrator: HealthCertificateMigration {
	
	func migrate(persons: [HealthCertifiedPerson]) -> [HealthCertifiedPerson] {
		var newHealthCertifiedPersons = regroup(persons: persons, runNumber: 0)
		newHealthCertifiedPersons.sort()
		for person in newHealthCertifiedPersons {
			person.healthCertificates = person.healthCertificates.sorted(by: <)
		}
		return newHealthCertifiedPersons
	}
	
	private func regroup(persons: [HealthCertifiedPerson], runNumber: Int) -> [HealthCertifiedPerson] {
		var mutablePersons = persons
		guard let referencePerson = mutablePersons.first else {
			return []
		}
		mutablePersons.removeFirst()
		var matchingPersons = [HealthCertifiedPerson]()
		
		for person in mutablePersons {
			for certificate in person.healthCertificates {
				for referenceCertificate in referencePerson.healthCertificates {
					if referenceCertificate.belongsToSamePerson(certificate) {
						matchingPersons.append(person)
					}
				}
			}
		}
		
		if runNumber == persons.count {
			mutablePersons.append(referencePerson)
			return mutablePersons
		}

		if matchingPersons.isEmpty {
			mutablePersons.append(referencePerson)
			return regroup(persons: mutablePersons, runNumber: runNumber + 1)
		} else {
			for matchingPerson in matchingPersons {
				referencePerson.healthCertificates += matchingPerson.healthCertificates
				mutablePersons.remove(matchingPerson)
			}
			mutablePersons.append(referencePerson)
			
			return regroup(persons: mutablePersons, runNumber: 0)
		}
	}
	
}
