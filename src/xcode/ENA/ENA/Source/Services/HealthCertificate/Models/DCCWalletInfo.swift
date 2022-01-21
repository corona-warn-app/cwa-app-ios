//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCWalletInfo: Codable, Equatable {

	let admissionState: DCCAdmissionState
	let vaccinationState: DCCVaccinationState
	let boosterNotification: DCCBoosterNotification
	let mostRelevantCertificate: DCCMostRelevantCertificate
	let verification: DCCVerification
	let validUntil: Date

}

struct DCCAdmissionState: Codable, Equatable {

	let visible: Bool
	let badgeText: LocalizedText?
	let titleText: LocalizedText?
	let subtitleText: LocalizedText?
	let longText: LocalizedText?
	let faqAnchor: String?

}

struct DCCVaccinationState: Codable, Equatable {

	let visible: Bool
	let titleText: LocalizedText?
	let subtitleText: LocalizedText?
	let longText: LocalizedText?
	let faqAnchor: String?

}

struct DCCBoosterNotification: Codable, Equatable {

	let visible: Bool
	let identifier: String?
	let titleText: LocalizedText?
	let subtitleText: LocalizedText?
	let longText: LocalizedText?
	let faqAnchor: String?

}

struct LocalizedText: Codable, Equatable {

}

struct DCCMostRelevantCertificate: Codable, Equatable {

	let certificateRef: DCCCertificateReference

}

struct DCCVerification: Codable, Equatable {

	let certificates: [DCCVerificationCertificate]

}

struct DCCVerificationCertificate: Codable, Equatable {

	let buttonText: LocalizedText
	let certificateRef: DCCCertificateReference

}

struct DCCCertificateReference: Codable, Equatable {

	let barcodeData: String

}

