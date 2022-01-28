//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable

extension DCCWalletInfo {

	static func fake(
		admissionState: DCCAdmissionState = .fake(),
		vaccinationState: DCCVaccinationState = .fake(),
		boosterNotification: DCCBoosterNotification = .fake(),
		mostRelevantCertificate: DCCMostRelevantCertificate = .fake(),
		verification: DCCVerification = .fake(),
		validUntil: Date = Date()
	) -> DCCWalletInfo {
		DCCWalletInfo(
			admissionState: admissionState,
			vaccinationState: vaccinationState,
			boosterNotification: boosterNotification,
			mostRelevantCertificate: mostRelevantCertificate,
			verification: verification,
			validUntil: validUntil
		)
	}

}

extension DCCAdmissionState {

	static func fake(
		visible: Bool = false,
		badgeText: DCCUIText? = nil,
		titleText: DCCUIText? = nil,
		subtitleText: DCCUIText? = nil,
		longText: DCCUIText? = nil,
		faqAnchor: String? = nil
	) -> DCCAdmissionState {
		DCCAdmissionState(
			visible: visible,
			badgeText: badgeText,
			titleText: titleText,
			subtitleText: subtitleText,
			longText: longText,
			faqAnchor: faqAnchor
		)
	}

}

extension DCCVaccinationState {

	static func fake(
		visible: Bool = false,
		titleText: DCCUIText? = nil,
		subtitleText: DCCUIText? = nil,
		longText: DCCUIText? = nil,
		faqAnchor: String? = nil
	) -> DCCVaccinationState {
		DCCVaccinationState(
			visible: visible,
			titleText: titleText,
			subtitleText: subtitleText,
			longText: longText,
			faqAnchor: faqAnchor
		)
	}

}

extension DCCBoosterNotification {

	static func fake(
		visible: Bool = false,
		identifier: String? = nil,
		titleText: DCCUIText? = nil,
		subtitleText: DCCUIText? = nil,
		longText: DCCUIText? = nil,
		faqAnchor: String? = nil
	) -> DCCBoosterNotification {
		DCCBoosterNotification(
			visible: visible,
			identifier: identifier,
			titleText: titleText,
			subtitleText: subtitleText,
			longText: longText,
			faqAnchor: faqAnchor
		)
	}

}

extension DCCUIText {

	static func fake(
		type: String = "string",
		quantity: Int? = nil,
		quantityParameterIndex: Int? = nil,
		functionName: String? = nil,
		localizedText: [String: AnyCodable]? = nil,
		parameters: AnyCodable
	) -> DCCUIText {
		DCCUIText(
			type: type,
			quantity: quantity,
			quantityParameterIndex: quantityParameterIndex,
			functionName: functionName,
			localizedText: localizedText,
			parameters: parameters
		)
	}

	static func fake(string: String) -> DCCUIText {
		.fake(type: "string", localizedText: ["de": AnyCodable(string)])
	}

}

extension DCCMostRelevantCertificate {

	static func fake(
		certificateRef: DCCCertificateReference = .fake()
	) -> DCCMostRelevantCertificate {
		DCCMostRelevantCertificate(
			certificateRef: certificateRef
		)
	}

}

extension DCCVerification {

	static func fake(
		certificates: [DCCVerificationCertificate] = []
	) -> DCCVerification {
		DCCVerification(
			certificates: certificates
		)
	}

}

extension DCCVerificationCertificate {

	static func fake(
		buttonText: DCCUIText = .fake(),
		certificateRef: DCCCertificateReference = .fake()
	) -> DCCVerificationCertificate {
		DCCVerificationCertificate(
			buttonText: buttonText,
			certificateRef: certificateRef
		)
	}

}

extension DCCCertificateReference {

	static func fake(
		barcodeData: String = ""
	) -> DCCCertificateReference {
		DCCCertificateReference(
			barcodeData: barcodeData
		)
	}

}
