//
// 🦠 Corona-Warn-App
//

import HealthCertificateToolkit
import Foundation

// swiftlint:disable line_length
// swiftlint:disable function_body_length
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
		if LaunchArguments.healthCertificate.reissuanceCertificates.boolValue {
			registerHealthCertificate(
				base45: firstReissuanceBase45,
				completedNotificationRegistration: { }
			)
			registerHealthCertificate(
				base45: secondReissuanceBase45,
				completedNotificationRegistration: { }
			)
			registerHealthCertificate(
				base45: thirdReissuanceBase45,
				completedNotificationRegistration: { }
			)
			registerHealthCertificate(
				base45: forthReissuanceBase45,
				completedNotificationRegistration: { }
			)
			registerHealthCertificate(
				base45: fifthReissuanceBase45,
				completedNotificationRegistration: { }
			)
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
			maskState: dccWalletInfo.maskState,
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

		let longText = DCCUIText(
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
			maskState: dccWalletInfo.maskState,
			boosterNotification: dccWalletInfo.boosterNotification,
			mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
			verification: dccWalletInfo.verification,
			validUntil: dccWalletInfo.validUntil,
			certificateReissuance: DCCCertificateReissuance(
				reissuanceDivision: DCCCertificateReissuanceDivision(
					visible: true,
					titleText: titleText,
					subtitleText: subtitleText,
					longText: longText,
					faqAnchor: "certificateReissuance",
					identifier: "renew",
					listTitleText: listTitleText,
					consentSubtitleText: subtitleText
				),
				certificateToReissue: nil,
				accompanyingCertificates: nil,
				certificates: [
					DCCReissuanceCertificateContainer(
						certificateToReissue: DCCCertificateContainer(
							certificateRef: DCCCertificateReference(barcodeData: firstReissuanceBase45)
						),
						accompanyingCertificates: [
							DCCCertificateContainer(
								certificateRef: DCCCertificateReference(barcodeData: secondReissuanceBase45)
							),
							DCCCertificateContainer(
								certificateRef: DCCCertificateReference(barcodeData: thirdReissuanceBase45)
							),
							DCCCertificateContainer(
								certificateRef: DCCCertificateReference(barcodeData: forthReissuanceBase45)
							)
						],
						action: "renew"
					),
					DCCReissuanceCertificateContainer(
						certificateToReissue: DCCCertificateContainer(
							certificateRef: DCCCertificateReference(barcodeData: fifthReissuanceBase45)
						),
						accompanyingCertificates: [],
						action: "renew"
					)
				]
			),
			certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
		)
	}
	
	func updateDccWalletInfoForMockRequiredMaskState(dccWalletInfo: DCCWalletInfo) -> DCCWalletInfo {
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Maskenpflicht"],
			parameters: []
		)
		
		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Sie Sind nicht von der Maskenpflicht ausgenommen"],
			parameters: []
		)
		
		let badgeText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Maskenpflicht"],
			parameters: []
		)
		
		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Von der Maskenpflicht sind alle Personen befreit, die innerhalb der letzten 3 Monate geimpft wurden oder genesen sind oder innerhalb der letzten 24 Stunden negativ getestet wurden."],
			parameters: []
		)
		
		return DCCWalletInfo(
			admissionState: dccWalletInfo.admissionState,
			vaccinationState: dccWalletInfo.vaccinationState,
			maskState: DCCMaskState(visible: true, badgeText: badgeText, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: "maskstate", identifier: .maskRequired),
			boosterNotification: dccWalletInfo.boosterNotification,
			mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
			verification: dccWalletInfo.verification,
			validUntil: dccWalletInfo.validUntil,
			certificateReissuance: dccWalletInfo.certificateReissuance,
			certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
		)
	}
	
	func updateDccWalletInfoForMockOptionalMaskState(dccWalletInfo: DCCWalletInfo) -> DCCWalletInfo {
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Keine Maskenpflicht"],
			parameters: []
		)
		
		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Eine Maske ist dennoch empfohlen"],
			parameters: []
		)
		
		let badgeText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Keine Maskenpflicht"],
			parameters: []
		)
		
		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Von der Maskenpflicht sind alle Personen befreit, die innerhalb der letzten 3 Monate geimpft wurden oder genesen sind oder innerhalb der letzten 24 Stunden negativ getestet wurden."],
			parameters: []
		)
		
		return DCCWalletInfo(
			admissionState: dccWalletInfo.admissionState,
			vaccinationState: dccWalletInfo.vaccinationState,
			maskState: DCCMaskState(visible: true, badgeText: badgeText, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: "maskstate", identifier: .maskOptional),
			boosterNotification: dccWalletInfo.boosterNotification,
			mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
			verification: dccWalletInfo.verification,
			validUntil: dccWalletInfo.validUntil,
			certificateReissuance: dccWalletInfo.certificateReissuance,
			certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
		)
	}
	private var firstReissuanceBase45: String {
		"HC1:6BFOXN*TS0BI$ZDFRH5TSWK3*93X+01V80RBZEJ8USXG43NI 7EFXRV7P4XUS4FDMP7JM:UC*GP-S4FT5D75W9AV88E34L/5R3F9JAY-BI9EW+9K.CMIAO/B.OC4-9D.B6LFDC9 AE 2AB7LOKEH-BXPLV6I-TL8KES/F-1JZ.KBIH:HG43MWY8%FAGUU0QIRR97I2HOAXL92L0: KQMK8J4RK46YBBOAXM42%K:XFEK0OH6PO9:TUQJAJG9-*NIRICVELZUZM9EN9-O97LAQCK /P/T14SIWG9$R7064B69X5QNEQT56QHE+.6L80TM8$M8SNCNAK09TU*5KGIDPS7A8Q/DA-7TLOJ3KV:BW.7-$4UGGBEG*Z1W1O4WDQETN:523EDZT/P7+7S/ZEJZ9Q:NIBV84W1-HGN33SNVMAS6C4XL QQU6S9QLJ KX$FTDAM2H3TS3KNY%AI:OF/9NHB%3KKS06GBF E"
	}
	private var secondReissuanceBase45: String {
		"HC1:6BFOXN*TS0BI$ZDFRH5TSWK3*93X+01V80RBZEJ8USXG41+Q53BF2UUVSY+LPLR$G6*P5-FJLF6EB9UM97H98$QJEQ8999Q9E$BLZIN4JZVBNPAZIJDZIA9J:CJVTIM7JZ0K3LILT39N2+NT ZJ83BGVTJ SPTTWZJ$7K+ CZED:NK0AC.PD%GI6+Q4U77Q4UYQD*O%+Q.SQBDO4C53752HPPEPHCRTWAQDPN95N14$BGP+P6OIB.VT*QNC2BFUF$SU%BO*N5PIBPIAOI5XIXCL9M6KN4C KUGAACQ+9AMDPN95ZTM+CSUHQN%A400H%UBT16Y5+Z9Q+6+YTJ.G/FV4$0RQJD*G+19EDB6LB/93%IJEUFPVN7096Q2C RJ$084ADY6T0Q GQOKL*OGL2H8AW.V98ZUOTMBWG/TMAL9FOJR5LE4N-%P42C%M661PJHD27O47G$JBM4AN8H44UCNS*70L0CS8R62E"
	}
	private var thirdReissuanceBase45: String {
		"HC1:6BFOXN*TS0BI$ZDFRH5TSWK3*93X+0/R8PJENDC2LE $C8L924AZSC.0UEP8%QB.N9/$HNO4*J8/Y4F%CD 810H% 0R%0IGF5JNBPI3$UNKGWSE*E6.UIOSUOW3GKETZUYZQTK9FKGJ+F:Q7/UIGSU6HA*%F0YBJMI:TU+MMPZ5SZ9MX1X%EWP5JUPY0BD-I/2DBAJDAJCNB-43 X4VV2 73-E3GG3V2035TPHN6D7LLK*2HG%89UV-0LZ 2MKN4NN3F85QNCY0O%0VZ001H9B9LGFUE9.959B9LW4T*8Y70-I0%YB/VM$*SHEKHRIJRH.OG4SIIRH/R2UZUWM6J$7XLH5G6TH9$NI4L6H%UFP1$XBHU1Z48EFC%3OQ8L-+KRYGSTIM*GJGDM9MGUJOQEKCH78OQXICZGAX6H7RNB5P1W27N*MV0/PFWMGWKRFFM9MP2H44N9TSA.6J2Q6AWCAM6E7.$C8R5ZCQT.VO$OP6OU5Q9D5FRV8CB*SA/JFM1CT:MKS032SD1F"
	}
	private var forthReissuanceBase45: String {
		"HC1:6BFOXN*TS0BI$ZDFRH5TSWK3*93X+0/R8PJENDC2LE $CIJ90UV%Y3+5EXM392H8ZBVODSA3/-2E%5G%5TW5A 6YO6XL6Q3QR$P*NI92K9$2BHJX1J0DJV1JQTTOTIKOJ:ZJ83BZZ2.KTS8T8DJC0JZPI*JTQ SM7J5OI9YI:8DH:D%PDB2M5WCHABVCNAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L67PPDFPVX1R270:6NEQ0R6AOM*PP:+P*.1D9R+Q6646C%6RF6VY9UKP-G9++9SH9WC5ME62H1DG3ZQTKJ3SZ4:L0K-JGDBVF2$7K*IBQQKV-J2 JDZT:1BPMIMIA*NIKYJHIKDBCLTSL1E.G0X51J.UN-PP:V$ BEZ5YW37NG R78J4TO8BM4W.PKUB2E4G$5+HJ%K4OGD.+841UTCQE0L*4R Z7D/MTWK9T9CLD SU8:AYN4K2N0QFK.6L4QOLFK2BI/B*YIN4EBMDWN4 920YTQCT7+E/UUX%K+00NHT.3"
	}
	private var fifthReissuanceBase45: String {
		"HC1:6BFOXN*TS0BI$ZDFRH5TSWK3*93X+0/R8PJENDC2LE $CIJ9BYQPCPA RB2HL:M8ZBVODSA3/-2E%5G%5TW5A 6YO6XL6Q3QR$P*NI92K9$2BHJX1J0DJV1JQTTOTIKOJ:ZJ83BZZ2.KTS8T8DJC0JZPI*JTQ SM7J5OI9YI:8DH:D%PDB2M5WCHABVCNAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L67PPDFPVX1R270:6NEQ0R6AOM*PP:+P*.1D9R+Q6646C%6RF6VY9UKPU*9++9H+9WC5ME62H1DG34LTPAJSZ4:L0K-JGDBVF2$7K*IBQQKV-J2 JDZT:1BPMIMIA*NIKYJHIKDBCLTSL1E.G0X510-UWS9ZZH K4R%H0O43.VTOO*S1:XBYVFKSBMU92E4TU6F*JP/E4.8.QVLXC-QRNMU025PVREAR 5M94KXGTKUTQCRK1AC9LLHB$CNTKO*B5ZN5SCQK*EALAOQ9WMH0O6V0ESBAL7L+-L XA$40G$121"
	}

	#endif
}
