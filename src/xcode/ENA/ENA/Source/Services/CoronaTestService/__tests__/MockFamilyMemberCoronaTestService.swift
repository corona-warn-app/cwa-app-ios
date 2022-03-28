////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit
@testable import ENA

class MockFamilyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding {

	// MARK: - Protocol CoronaTestServiceProviding

	var coronaTests = CurrentValueSubject<[FamilyMemberCoronaTest], Never>([])

	func upToDateTest(for coronaTest: FamilyMemberCoronaTest) -> FamilyMemberCoronaTest? {
		coronaTests.value.first { $0.qrCodeHash == coronaTest.qrCodeHash }
	}
	
	func registerPCRTestAndGetResult(
		for displayName: String,
		guid: String,
		qrCodeHash: String,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		onRegisterPCRTestAndGetResult()
		completion(registerPCRTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

	func registerAntigenTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		onRegisterAntigenTestAndGetResult()
		completion(registerAntigenTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}

	func registerRapidPCRTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		onRegisterRapidPCRTestAndGetResult()
		completion(registerRapidPCRTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}
	
	func reregister(coronaTest: FamilyMemberCoronaTest) {}

	func updateTestResults(
		presentNotification: Bool,
		completion: @escaping VoidResultHandler
	) {}

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	) {
		onUpdateTestResult(coronaTest, presentNotification)
		completion(updateTestResultResult ?? .failure(.noRegistrationToken))
	}

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest) {
		onMoveTestToBin(coronaTest)
	}

	func removeTest(_ coronaTest: FamilyMemberCoronaTest) {}

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest) {}

	func evaluateShowingAllTests() {}

	func updatePublishersFromStore() {}
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		return nil
	}
	
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
		_ coronaTest: FamilyMemberCoronaTest,
		_ presentNotification: Bool
	) -> Void = { _, _ in }

	var getSubmissionTANResult: Result<String, CoronaTestServiceError>?

	var onMoveTestToBin: (
		_ coronaTest: FamilyMemberCoronaTest
	) -> Void = { _ in }

}
