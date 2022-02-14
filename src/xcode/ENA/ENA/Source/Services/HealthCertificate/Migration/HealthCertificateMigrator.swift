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
		
		var newHealthCertifiedPersons = regroup(originalPersons: store.healthCertifiedPersons)
		newHealthCertifiedPersons.sort()
		for person in newHealthCertifiedPersons {
			person.healthCertificates = person.healthCertificates.sorted(by: <)
		}
		store.healthCertifiedPersons = newHealthCertifiedPersons
	}
		
	private func regroup(
		originalPersons: [HealthCertifiedPerson]
	) -> [HealthCertifiedPerson] {
		var regroupedPersons = [HealthCertifiedPerson]()
		let allCertificates = originalPersons.flatMap {
			$0.healthCertificates
		}
		
		for certificate in allCertificates {
			let matchingOriginalPersons = findPersons(for: certificate, from: originalPersons)
			let matchingRegroupedPersons = findPersons(for: certificate, from: regroupedPersons)
			
			for matchingRegroupedPerson in matchingRegroupedPersons {
				regroupedPersons.remove(matchingRegroupedPerson)
			}
			
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
				applyPropertiesToPerson(matchingPerson, firstPerson)
			}
			
			regroupedPersons.append(firstPerson)
		}
		
		return regroupedPersons
	}
	
	private func findPersons(
		for certificate: HealthCertificate,
		from persons: [HealthCertifiedPerson]
	) -> [HealthCertifiedPerson] {
		var foundPersons = [HealthCertifiedPerson]()

		for person in persons {
			for personCertificate in person.healthCertificates {
				if certificate.belongsToSamePerson(personCertificate) {
					foundPersons.append(person)
				}
			}
		}
		
		return foundPersons
	}
	
	private func applyPropertiesToPerson(
		_ matchingPerson: HealthCertifiedPerson,
		_ firstPerson: HealthCertifiedPerson
	) {
		if matchingPerson.isPreferredPerson {
			firstPerson.isPreferredPerson = true
		}
		if matchingPerson.boosterRule != nil {
			firstPerson.boosterRule = matchingPerson.boosterRule
		}
		if matchingPerson.isNewBoosterRule {
			firstPerson.isNewBoosterRule = true
		}
		if matchingPerson.mostRecentWalletInfoUpdateFailed {
			firstPerson.mostRecentWalletInfoUpdateFailed = true
		}
	}
}
