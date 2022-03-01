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
		let oldPersons = store.healthCertifiedPersons
		var newHealthCertifiedPersons = regroup(originalPersons: store.healthCertifiedPersons)
		newHealthCertifiedPersons.sort()
		for person in newHealthCertifiedPersons {
			person.healthCertificates = person.healthCertificates.sorted(by: <)
		}
		store.healthCertifiedPersons = newHealthCertifiedPersons
		let newPersons = newHealthCertifiedPersons
		store.shouldShowRegroupingAlert = oldPersons != newPersons
	}
		
	private func regroup(
		originalPersons: [HealthCertifiedPerson]
	) -> [HealthCertifiedPerson] {
		var regroupedPersons = [HealthCertifiedPerson]()
		let allCertificates = originalPersons.flatMap {
			$0.healthCertificates
		}
		
		for certificate in allCertificates {
			let matchingOriginalPersons = originalPersons.findPersons(for: certificate)
			let matchingRegroupedPersons = regroupedPersons.findPersons(for: certificate)
			
			regroupedPersons.remove(elements: matchingRegroupedPersons)
			
			let allPersons = matchingOriginalPersons + matchingRegroupedPersons
			guard let firstPerson = allPersons.first else {
				continue
			}
			
			for matchingPerson in allPersons {
				for certificate in matchingPerson.healthCertificates {
					if !firstPerson.healthCertificates.contains(certificate) {
						firstPerson.healthCertificates.append(certificate)
					}
				}
				
				if matchingPerson.isPreferredPerson {
					firstPerson.isPreferredPerson = true
				}
			}
			
			regroupedPersons.append(firstPerson)
		}
		
		return regroupedPersons
	}
}
