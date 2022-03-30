////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit
@testable import ENA

class MockCoronaTestService: CoronaTestServiceProviding {

	// MARK: - Init

	init() {

	}

	// MARK: - Protocol CoronaTestServiceProviding

	var pcrTest = CurrentValueSubject<UserPCRTest?, Never>(nil)
	var antigenTest = CurrentValueSubject<UserAntigenTest?, Never>(nil)

	var antigenTestIsOutdated = CurrentValueSubject<Bool, Never>(false)

	var pcrTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)
	var antigenTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)

	func coronaTest(ofType type: CoronaTestType) -> UserCoronaTest? {
		switch type {
		case .pcr:
			return pcrTest.value.map { .pcr($0) }
		case .antigen:
			return antigenTest.value.map { .antigen($0) }
		}
	}
	
	// This function is responsible to register a PCR test from QR Code
	func registerPCRTestAndGetResult(
		guid: String,
		qrCodeHash: String,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		onRegisterPCRTestAndGetResult()
		completion(registerPCRTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

	// This function is responsible to register a PCR test from TeleTAN
	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping (Result<Void, CoronaTestServiceError>) -> Void
	) {
		onRegisterPCRTestFromTeleTan()
		completion(registerPCRTestFromTeleTanResult ?? .failure(.noCoronaTestOfRequestedType))
	}
	
	func registerPCRTestAndGetResult(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		onRegisterPCRTestFromTeleTanAndGetResult()
		completion(registerPCRTestFromTeleTanAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

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
	) {
		onRegisterAntigenTestAndGetResult()
		completion(registerAntigenTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

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
	) {
		onRegisterRapidPCRTestAndGetResult()
		completion(registerRapidPCRTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}
	
	func reregister(coronaTest: UserCoronaTest) {}

	func updateTestResults(force: Bool, presentNotification: Bool, completion: @escaping VoidResultHandler) {}

	func updateTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	) {
		onUpdateTestResult(coronaTestType, force, presentNotification)
		completion(updateTestResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

	func getSubmissionTAN(for coronaTestType: CoronaTestType, completion: @escaping SubmissionTANResultHandler) {
		completion(getSubmissionTANResult ?? .success("submissionTAN"))
	}

	func moveTestToBin(_ coronaTestType: CoronaTestType) {
		onMoveTestToBin(coronaTestType)
	}

	func removeTest(_ coronaTestType: CoronaTestType) {}

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType) {}

	func evaluateSavingTestToDiary(ofTestType coronaTestType: CoronaTestType) {}
	
	func updatePublishersFromStore() {}

	func migrate() {}
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		return nil
	}

	func createCoronaTestEntryInContactDiary(coronaTestType: CoronaTestType?) {}
	
	#if DEBUG

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		return nil
	}

	#endif

	// MARK: - Internal

	var registerPCRTestAndGetResultResult: Result<TestResult, CoronaTestServiceError>?
	var onRegisterPCRTestAndGetResult: () -> Void = { }

	var registerPCRTestFromTeleTanResult: Result<Void, CoronaTestServiceError>?
	var onRegisterPCRTestFromTeleTan: () -> Void = { }

	var registerPCRTestFromTeleTanAndGetResultResult: Result<TestResult, CoronaTestServiceError>?
	var onRegisterPCRTestFromTeleTanAndGetResult: () -> Void = { }

	var registerAntigenTestAndGetResultResult: Result<TestResult, CoronaTestServiceError>?
	var onRegisterAntigenTestAndGetResult: () -> Void = { }

	var registerRapidPCRTestAndGetResultResult: Result<TestResult, CoronaTestServiceError>?
	var onRegisterRapidPCRTestAndGetResult: () -> Void = { }

	var updateTestResultResult: Result<TestResult, CoronaTestServiceError>?
	var onUpdateTestResult: (
		_ coronaTestType: CoronaTestType,
		_ force: Bool,
		_ presentNotification: Bool
	) -> Void = { _, _, _ in }

	var getSubmissionTANResult: Result<String, CoronaTestServiceError>?

	var onMoveTestToBin: (
		_ coronaTestType: CoronaTestType
	) -> Void = { _ in }

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
