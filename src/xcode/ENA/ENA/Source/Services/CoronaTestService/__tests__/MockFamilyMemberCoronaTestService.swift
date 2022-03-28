////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit
@testable import ENA

class MockFamilyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding {

	// MARK: - Init

	init() {

	}

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
		completion: @escaping RegistrationResultHandler
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
		completion: @escaping RegistrationResultHandler
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
		completion: @escaping RegistrationResultHandler
	) {
		onRegisterRapidPCRTestAndGetResult()
		completion(registerRapidPCRTestAndGetResultResult ?? .failure(.noCoronaTestOfRequestedType))
	}
	
	func reregister(coronaTest: FamilyMemberCoronaTest) {}

	func updateTestResults(force: Bool, presentNotification: Bool, completion: @escaping VoidResultHandler) {}

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		force: Bool,
		presentNotification: Bool,
		completion: @escaping TestResultHandler
	) {
		onUpdateTestResult(coronaTest, force, presentNotification)
		completion(updateTestResultResult ?? .failure(.noRegistrationToken))
	}

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest) {
		onMoveTestToBin(coronaTest)
	}

	func removeTest(_ coronaTest: FamilyMemberCoronaTest) {}

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest) {}

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

	var registerPCRTestAndGetResultResult: Result<FamilyMemberCoronaTest, CoronaTestServiceError>?
	var onRegisterPCRTestAndGetResult: () -> Void = { }

	var registerPCRTestFromTeleTanResult: Result<Void, CoronaTestServiceError>?
	var onRegisterPCRTestFromTeleTan: () -> Void = { }

	var registerPCRTestFromTeleTanAndGetResultResult: Result<TestResult, CoronaTestServiceError>?
	var onRegisterPCRTestFromTeleTanAndGetResult: () -> Void = { }

	var registerAntigenTestAndGetResultResult: Result<FamilyMemberCoronaTest, CoronaTestServiceError>?
	var onRegisterAntigenTestAndGetResult: () -> Void = { }

	var registerRapidPCRTestAndGetResultResult: Result<FamilyMemberCoronaTest, CoronaTestServiceError>?
	var onRegisterRapidPCRTestAndGetResult: () -> Void = { }

	var updateTestResultResult: Result<TestResult, CoronaTestServiceError>?
	var onUpdateTestResult: (
		_ coronaTest: FamilyMemberCoronaTest,
		_ force: Bool,
		_ presentNotification: Bool
	) -> Void = { _, _, _ in }

	var getSubmissionTANResult: Result<String, CoronaTestServiceError>?

	var onMoveTestToBin: (
		_ coronaTest: FamilyMemberCoronaTest
	) -> Void = { _ in }

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
