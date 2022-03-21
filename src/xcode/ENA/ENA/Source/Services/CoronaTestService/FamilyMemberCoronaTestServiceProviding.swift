////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

protocol CoronaTestServiceProviding {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias TestResultHandler = (Result<TestResult, CoronaTestServiceError>) -> Void
	typealias CoronaTestHandler = (Result<CoronaTest, CoronaTestServiceError>) -> Void
	typealias SubmissionTANResultHandler = (Result<String, CoronaTestServiceError>) -> Void

	var pcrTest: CurrentValueSubject<UserPCRTest?, Never> { get set }
	var antigenTest: CurrentValueSubject<UserAntigenTest?, Never> { get set }

	var antigenTestIsOutdated: CurrentValueSubject<Bool, Never> { get }

	var pcrTestResultIsLoading: CurrentValueSubject<Bool, Never> { get }
	var antigenTestResultIsLoading: CurrentValueSubject<Bool, Never> { get }

	var familyMemberTests: CurrentValueSubject<[FamilyMemberCoronaTest], Never> { get }

	func userCoronaTest(ofType type: CoronaTestType) -> UserCoronaTest?
	
	// This function is responsible to register a PCR test from QR Code
	func registerPCRTestAndGetResult(
		guid: String,
		qrCodeHash: String,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)

	// This function is responsible to register a PCR test from TeleTAN
	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping (Result<Void, CoronaTestServiceError>) -> Void
	)
	
	func registerPCRTestAndGetResult(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	)

	// swiftlint:disable:next function_parameter_count
	func registerAntigenTestAndGetResult(
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)

	// swiftlint:disable:next function_parameter_count
	func registerRapidPCRTestAndGetResult(
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	)
	
	func reregister(coronaTest: UserCoronaTest)

	func updateTestResults(force: Bool, presentNotification: Bool, completion: @escaping VoidResultHandler)

	func updateTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	)

	func getSubmissionTAN(for coronaTestType: CoronaTestType, completion: @escaping SubmissionTANResultHandler)

	func moveTestToBin(_ coronaTestType: CoronaTestType)

	func removeTest(_ coronaTestType: CoronaTestType)

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType)

	func updatePublishersFromStore()

	func migrate()
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?

	func createCoronaTestEntryInContactDiary(coronaTestType: CoronaTestType?)
	
	#if DEBUG

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?

	#endif

}

extension CoronaTestServiceProviding {

	func updateTestResults(force: Bool = true, presentNotification: Bool, completion: @escaping VoidResultHandler) {
		updateTestResults(
			force: force,
			presentNotification: presentNotification,
			completion: completion
		)
	}

	func updateTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool = true,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		updateTestResult(
			for: coronaTestType,
			force: force,
			presentNotification: presentNotification,
			completion: completion
		)
	}

}
