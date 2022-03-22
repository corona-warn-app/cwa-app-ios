////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

protocol FamilyMemberCoronaTestServiceProviding {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias TestResultHandler = (Result<TestResult, CoronaTestServiceError>) -> Void

	var coronaTests: CurrentValueSubject<[FamilyMemberCoronaTest], Never> { get }

	// This function is responsible to register a PCR test from QR Code
	func registerPCRTestAndGetResult(
		for displayName: String,
		guid: String,
		qrCodeHash: String,
		isSubmissionConsentGiven: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)

	// swiftlint:disable:next function_parameter_count
	func registerAntigenTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		isSubmissionConsentGiven: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)

	// swiftlint:disable:next function_parameter_count
	func registerRapidPCRTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		isSubmissionConsentGiven: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)
	
	func reregister(coronaTest: FamilyMemberCoronaTest)

	func updateTestResults(force: Bool, presentNotification: Bool, completion: @escaping VoidResultHandler)

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		force: Bool,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	)

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest)

	func removeTest(_ coronaTest: FamilyMemberCoronaTest)

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest)

	func updatePublishersFromStore()
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?
	
	#if DEBUG

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?

	#endif

}

extension FamilyMemberCoronaTestServiceProviding {

	func updateTestResults(force: Bool = true, presentNotification: Bool, completion: @escaping VoidResultHandler) {
		updateTestResults(
			force: force,
			presentNotification: presentNotification,
			completion: completion
		)
	}

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		force: Bool = true,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		updateTestResult(
			for: coronaTest,
			force: force,
			presentNotification: presentNotification,
			completion: completion
		)
	}

}
