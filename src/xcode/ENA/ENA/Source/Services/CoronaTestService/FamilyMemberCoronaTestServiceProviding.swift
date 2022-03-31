////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

protocol FamilyMemberCoronaTestServiceProviding {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<FamilyMemberCoronaTest, CoronaTestServiceError>) -> Void
	typealias RegistrationTokenResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias TestResultHandler = (Result<TestResult, CoronaTestServiceError>) -> Void

	var coronaTests: CurrentValueSubject<[FamilyMemberCoronaTest], Never> { get }

	var unseenNewsCount: Int { get }

	func upToDateTest(for coronaTest: FamilyMemberCoronaTest) -> FamilyMemberCoronaTest?

	func registerPCRTestAndGetResult(
		for displayName: String,
		guid: String,
		qrCodeHash: String,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	)

	func registerAntigenTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	)

	func registerRapidPCRTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	)
	
	func reregister(coronaTest: FamilyMemberCoronaTest)

	func updateTestResults(
		presentNotification: Bool,
		completion: @escaping VoidResultHandler
	)

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	)

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest)

	func removeTest(_ coronaTest: FamilyMemberCoronaTest)

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest)

	func evaluateShowingAllTests()

	func updatePublishersFromStore()
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?
	
	#if DEBUG

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?

	#endif

}
