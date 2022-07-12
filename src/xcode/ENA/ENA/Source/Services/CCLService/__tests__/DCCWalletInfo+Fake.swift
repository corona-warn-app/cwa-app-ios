//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable

@testable import ENA

extension DCCWalletInfo {

	static func fake(
		admissionState: DCCAdmissionState = .fake(),
		vaccinationState: DCCVaccinationState = .fake(),
		boosterNotification: DCCBoosterNotification = .fake(),
		mostRelevantCertificate: DCCCertificateContainer = .fake(),
		verification: DCCVerification = .fake(),
		validUntil: Date = Date(),
		certificateReissuance: DCCCertificateReissuance? = nil,
		certificatesRevokedByInvalidationRules: [DCCCertificateContainer] = []
	) -> DCCWalletInfo {
		DCCWalletInfo(
			admissionState: admissionState,
			vaccinationState: vaccinationState,
			boosterNotification: boosterNotification,
			mostRelevantCertificate: mostRelevantCertificate,
			verification: verification,
			validUntil: validUntil,
			certificateReissuance: certificateReissuance,
			certificatesRevokedByInvalidationRules: certificatesRevokedByInvalidationRules
		)
	}

}

extension DCCAdmissionCheckScenarios {
	static func fake(
		labelText: DCCUIText = .fake(),
		scenarioSelection: DCCScenarioSelection = .fake()
	) -> DCCAdmissionCheckScenarios {
		DCCAdmissionCheckScenarios(
			labelText: labelText,
			scenarioSelection: scenarioSelection)
	}
}

extension DCCScenarioSelection {
	static func fake(
		titleText: DCCUIText = .fake(),
		items: [DCCScenarioSelectionItem] = []
	) -> DCCScenarioSelection {
		DCCScenarioSelection(
			titleText: titleText,
			items: items
		)
	}
}

extension DCCAdmissionState {

	static func fake(
		identifier: String? = nil,
		visible: Bool = false,
		badgeText: DCCUIText? = nil,
		titleText: DCCUIText? = nil,
		subtitleText: DCCUIText? = nil,
		stateChangeNotificationText: DCCUIText? = nil,
		longText: DCCUIText? = nil,
		faqAnchor: String? = nil
	) -> DCCAdmissionState {
		DCCAdmissionState(
			identifier: identifier,
			visible: visible,
			badgeText: badgeText,
			titleText: titleText,
			subtitleText: subtitleText,
			stateChangeNotificationText: stateChangeNotificationText,
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
		parameters: AnyCodable = []
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

extension DCCCertificateContainer {

	static func fake(
		certificateRef: DCCCertificateReference = .fake()
	) -> DCCCertificateContainer {
		DCCCertificateContainer(
			certificateRef: certificateRef
		)
	}

}

extension DCCReissuanceCertificateContainer {

	static func fake(
		certificateToReissue: DCCCertificateContainer = .fake(),
		accompanyingCertificates: [DCCCertificateContainer] = [.fake()],
		action: String = "renew"
	) -> DCCReissuanceCertificateContainer {
		DCCReissuanceCertificateContainer(
			certificateToReissue: certificateToReissue,
			accompanyingCertificates: accompanyingCertificates,
			action: action
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

extension DCCCertificateReissuance {

	static func fake(
		reissuanceDivision: DCCCertificateReissuanceDivision = .fake(),
		certificateToReissue: DCCCertificateContainer = .fake(),
		accompanyingCertificates: [DCCCertificateContainer] = [.fake()],
		certificates: [DCCReissuanceCertificateContainer] = [.fake()]
	) -> DCCCertificateReissuance {
		DCCCertificateReissuance(
			reissuanceDivision: reissuanceDivision,
			certificateToReissue: certificateToReissue,
			accompanyingCertificates: accompanyingCertificates,
			certificates: certificates
		)
	}

}

extension DCCCertificateReissuanceDivision {

	static func fake(
		visible: Bool = false,
		identifier: String? = nil,
		listTitleText: DCCUIText? = nil,
		titleText: DCCUIText? = nil,
		consentSubtitleText: DCCUIText? = nil,
		subtitleText: DCCUIText? = nil,
		longText: DCCUIText? = nil,
		faqAnchor: String? = nil
	) -> DCCCertificateReissuanceDivision {
		DCCCertificateReissuanceDivision(
			visible: visible,
			titleText: titleText,
			subtitleText: subtitleText,
			longText: longText,
			faqAnchor: faqAnchor,
			identifier: identifier,
			listTitleText: listTitleText,
			consentSubtitleText: consentSubtitleText
		)
	}

}
