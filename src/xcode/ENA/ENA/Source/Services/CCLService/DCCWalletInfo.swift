//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable

struct DCCWalletInfo: Codable, Equatable {

	let admissionState: DCCAdmissionState
	let vaccinationState: DCCVaccinationState
	let boosterNotification: DCCBoosterNotification
	let mostRelevantCertificate: DCCMostRelevantCertificate
	let verification: DCCVerification
	let validUntil: Date?

}

struct DCCAdmissionCheckScenarios: Codable, Equatable {
	
	let labelText: DCCUIText
	let scenarioSelection: DCCScenarioSelection

}

struct DCCScenarioSelection: Codable, Equatable {
	
	let titleText: DCCUIText
	let items: [DCCScenarioSelectionItem]

}

struct DCCScenarioSelectionItem: Codable, Equatable {
	
	let identifier: String
	let titleText: DCCUIText
	let subtitleText: DCCUIText?
	let enabled: Bool

}

struct DCCAdmissionState: Codable, Equatable {

	let visible: Bool
	let badgeText: DCCUIText?
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCVaccinationState: Codable, Equatable {

	let visible: Bool
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCBoosterNotification: Codable, Equatable {

	let visible: Bool
	let identifier: String?
	let titleText: DCCUIText?
	let subtitleText: DCCUIText?
	let longText: DCCUIText?
	let faqAnchor: String?

}

struct DCCMostRelevantCertificate: Codable, Equatable {

	let certificateRef: DCCCertificateReference

}

struct DCCVerification: Codable, Equatable {

	let certificates: [DCCVerificationCertificate]

}

struct DCCVerificationCertificate: Codable, Equatable {

	let buttonText: DCCUIText
	let certificateRef: DCCCertificateReference

}

struct DCCCertificateReference: Codable, Equatable {

	let barcodeData: String?

}
