//
// 🦠 Corona-Warn-App
//

import HealthCertificateToolkit

extension HealthCertificateService {
	#if DEBUG
	// swiftlint:disable cyclomatic_complexity
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
			registerHealthCertificate(base45: HealthCertificateMocks.firstBase45Mock, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
		} else if LaunchArguments.healthCertificate.secondHealthCertificate.boolValue {
			let secondDose = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake(doseNumber: 2, uniqueCertificateIdentifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#E")]
				),
				header: .fake(issuer: "DE", expirationTime: expirationTime)
			)
			if case let .success(base45) = secondDose {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
			}
		} else if LaunchArguments.healthCertificate.firstAndSecondHealthCertificate.boolValue {
			// We need the specific case of issuer == "DE" to test the printing of health certificate.
			// If the issuer is not "DE", printing is not allowed.
			let issuer = LaunchArguments.healthCertificate.firstAndSecondHealthCertificateIssuerDE.boolValue ? "DE" : "Other"

			let firstDose = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake()]
				),
				header: CBORWebTokenHeader.fake(issuer: issuer, expirationTime: expirationTime)
			)
			if case let .success(base45) = firstDose {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
			}
			
			let secondDose = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					vaccinationEntries: [VaccinationEntry.fake(doseNumber: 2, uniqueCertificateIdentifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#E")]
				),
				header: CBORWebTokenHeader.fake(issuer: issuer, expirationTime: expirationTime)
			)
			if case let .success(base45) = secondDose {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
			}
		}

		if LaunchArguments.healthCertificate.familyCertificates.boolValue {
			let testCert1 = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z", uniqueCertificateIdentifier: "1")]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = testCert1 {
				registerHealthCertificate(base45: base45, completedNotificationRegistration: { })
			}
			let testCert2 = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Toni", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "TONI"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T17:01:00Z", uniqueCertificateIdentifier: "2")]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = testCert2 {
				registerHealthCertificate(base45: base45, completedNotificationRegistration: { })
			}
			let testCert3 = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Victoria", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "VICTORIA"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-13T18:01:00Z", uniqueCertificateIdentifier: "3")]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = testCert3 {
				registerHealthCertificate(base45: base45, completedNotificationRegistration: { })
			}
			let testCert4 = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Thomas", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "THOMAS"),
					testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-15T12:01:00Z", uniqueCertificateIdentifier: "4")]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = testCert4 {
				registerHealthCertificate(base45: base45, completedNotificationRegistration: { })
			}
		}

		if LaunchArguments.healthCertificate.testCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [
						.fake(
							dateTimeOfSampleCollection: ISO8601DateFormatter.string(from: Date(timeIntervalSinceNow: -60 * 60), timeZone: .utcTimeZone, formatOptions: [.withInternetDateTime])
						)
					]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
			}
		}

		if LaunchArguments.healthCertificate.newTestCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					testEntries: [.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)
			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, markAsNew: true, completedNotificationRegistration: { })
			}
		}

		if LaunchArguments.healthCertificate.recoveryCertificateRegistered.boolValue {
			let result = DigitalCovidCertificateFake.makeBase45Fake(
				certificate: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
					recoveryEntries: [
						.fake(
							dateOfFirstPositiveNAAResult: ISO8601DateFormatter.string(from: Date(timeIntervalSinceNow: -150 * 24 * 60 * 60), timeZone: .utcTimeZone, formatOptions: [.withFullDate]),
							certificateValidFrom: ISO8601DateFormatter.string(from: Date(timeIntervalSinceNow: -120 * 24 * 60 * 60), timeZone: .utcTimeZone, formatOptions: [.withFullDate]),
							certificateValidUntil: ISO8601DateFormatter.string(from: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60), timeZone: .utcTimeZone, formatOptions: [.withFullDate])
						)
					]
				),
				header: CBORWebTokenHeader.fake(expirationTime: expirationTime)
			)

			if case let .success(base45) = result {
				registerHealthCertificate(base45: base45, checkSignatureUpfront: shouldCheckSignatureUpfront, completedNotificationRegistration: { })
			}
		}
	}
	
	func updateDccWalletInfoForMockBoosterNotification(dccWalletInfo: DCCWalletInfo) -> DCCWalletInfo {
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Hinweis zur Auffrischimpfung"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "auf Grundlage Ihrer gespeicherten Zertifikate"],
			parameters: []
		)

		let testLongText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Die Ständige Impfkommission (STIKO) empfiehlt allen Personen eine weitere Impfstoffdosis zur Optimierung der Grundimmunisierung, die mit einer Dosis des Janssen-Impfstoffs (Johnson & Johnson) grundimmunisiert wurden, bei denen keine Infektion mit dem Coronavirus SARS-CoV-2 nachgewiesen wurde und wenn ihre Janssen-Impfung über 4 Wochen her ist."],
			parameters: []
		)

		return DCCWalletInfo(
			admissionState: dccWalletInfo.admissionState,
			vaccinationState: dccWalletInfo.vaccinationState,
			boosterNotification: DCCBoosterNotification(visible: true, identifier: "hello", titleText: titleText, subtitleText: subtitleText, longText: testLongText, faqAnchor: "test"),
			mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
			verification: dccWalletInfo.verification,
			validUntil: dccWalletInfo.validUntil,
			certificateReissuance: dccWalletInfo.certificateReissuance,
			certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
		)
	}

	func updateDccWalletInfoForMockCertificateReissuance(
		dccWalletInfo: DCCWalletInfo,
		certifiedPerson: HealthCertifiedPerson
	) -> DCCWalletInfo {
		let listTitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Zu erneuernde Zertifikate:"],
			parameters: []
		)
		
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Zertifikate erneuern"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Erneuerung direkt über die App vornehmen"],
			parameters: []
		)

		let testLongText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Für mindestens ein Zertifikat ist die Gültigkeit abgelaufen oder läuft in Kürze ab. Mit einem abgelaufenen Zertifikat können Sie Ihren Status nicht mehr nachweisen.\n\nIm Zeitraum von 28 Tagen vor Ablauf und bis zu 3 Monate nach Ablauf der Gültigkeit können Sie sich neue Zertifikate direkt kostenlos über die App ausstellen lassen. Hierfür ist Ihr Einverständnis erforderlich."],
			parameters: []
		)

		return DCCWalletInfo(
			admissionState: dccWalletInfo.admissionState,
			vaccinationState: dccWalletInfo.vaccinationState,
			boosterNotification: dccWalletInfo.boosterNotification,
			mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
			verification: dccWalletInfo.verification,
			validUntil: dccWalletInfo.validUntil,
			certificateReissuance: DCCCertificateReissuance(
				reissuanceDivision: DCCCertificateReissuanceDivision(
					visible: true,
					listTitleText: listTitleText,
					titleText: titleText,
					consentSubtitleText: subtitleText,
					subtitleText: subtitleText,
					longText: testLongText,
					faqAnchor: "certificateReissuance"
				),
				certificates: [DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: certifiedPerson.healthCertificates.last?.base45 ?? ""), display: true
				)]
			),
			certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
		)
	}
	#endif
}
