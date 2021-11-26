//
// 🦠 Corona-Warn-App
//

import HealthCertificateToolkit

extension HealthCertificateService {
	#if DEBUG
	// swiftlint:disable:next cyclomatic_complexity
	func configureForTesting() {
		var shouldCheckSignatureUpfront = true
		var expirationTime: Date = Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()

		if LaunchArguments.healthCertificate.isCertificateInvalid.boolValue {
			shouldCheckSignatureUpfront = false
		}

		if LaunchArguments.healthCertificate.isCertificateExpiring.boolValue {
			expirationTime = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
		}

		if LaunchArguments.healthCertificate.hasCertificateExpired.boolValue {
			expirationTime = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(timeIntervalSinceReferenceDate: -123456789.0) // Feb 2, 1997, 10:26 AM
		}
		
		if LaunchArguments.healthCertificate.firstHealthCertificate.boolValue {
			registerHealthCertificate(base45: HealthCertificateMocks.firstBase45Mock, checkSignatureUpfront: shouldCheckSignatureUpfront)
		} else if LaunchArguments.healthCertificate.secondHealthCertificate.boolValue {
			let secondDose = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake(doseNumber: 2, uniqueCertificateIdentifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#E")]
				),
				and: CBORWebTokenHeader.fake(issuer: "DE", expirationTime: expirationTime)
			)
			if case let .success(base45) = secondDose {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront)
			}
		} else if LaunchArguments.healthCertificate.firstAndSecondHealthCertificate.boolValue {
			// We need the specific case of issuer == "DE" to test the printing of health certificate.
			// If the issuer is not "DE", printing is not allowed.
			let issuer = LaunchArguments.healthCertificate.firstAndSecondHealthCertificateIssuerDE.boolValue ? "DE" : "Other"

			let firstDose = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake()]
				),
				and: CBORWebTokenHeader.fake(issuer: issuer, expirationTime: expirationTime)
			)
			if case let .success(base45) = firstDose {
				let result = registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront)

				if case let .success(certificateResult) = result,
					LaunchArguments.healthCertificate.hasBoosterNotification.boolValue {
					certificateResult.person.boosterRule = .fake(
						identifier: "EX-ID-005",
						description: [
							.fake(lang: "en", desc: "You may be eligible for a booster because your vaccination with Astra Zeneca was more than 5 months ago."),
							.fake(lang: "de", desc: "Sie könnten für eine Auffrischungsimpfung berechtigt sein, da Ihre Impfung mit Astra Zeneca vor mehr als 5 Monaten war.")
						]
					)
					certificateResult.person.isNewBoosterRule = true
				}
			}
			
			let secondDose = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake(doseNumber: 2, uniqueCertificateIdentifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#E")]
				),
				and: CBORWebTokenHeader.fake(issuer: issuer, expirationTime: expirationTime)
			)
			if case let .success(base45) = secondDose {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront)
			}
		}

		if LaunchArguments.healthCertificate.familyCertificates.boolValue {
			let testCert1 = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = testCert1 {
				registerHealthCertificate(base45: base45)
			}
			let testCert2 = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Toni", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "TONI"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T17:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = testCert2 {
				registerHealthCertificate(base45: base45)
			}
			let testCert3 = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Victoria", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "VICTORIA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-13T18:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = testCert3 {
				registerHealthCertificate(base45: base45)
			}
			let testCert4 = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Thomas", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "THOMAS"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-15T12:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = testCert4 {
				registerHealthCertificate(base45: base45)
			}
		}

		if LaunchArguments.healthCertificate.testCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront)
			}
		}

		if LaunchArguments.healthCertificate.newTestCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
				),
				and: CBORWebTokenHeader.fake()
			)
			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, markAsNew: true)
			}
		}

		if LaunchArguments.healthCertificate.recoveryCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					recoveryEntries: [
						RecoveryEntry.fake()
					]
				),
				and: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)

			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront)
			}
		}
	}
	#endif
}
