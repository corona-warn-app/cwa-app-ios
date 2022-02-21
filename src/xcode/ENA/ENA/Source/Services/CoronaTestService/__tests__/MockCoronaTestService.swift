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

	var pcrTest = CurrentValueSubject<PCRTest?, Never>(nil)
	var antigenTest = CurrentValueSubject<AntigenTest?, Never>(nil)

	var antigenTestIsOutdated = CurrentValueSubject<Bool, Never>(false)

	var pcrTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)
	var antigenTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)

	var hasAtLeastOneShownPositiveOrSubmittedTest: Bool = false

	func coronaTest(ofType type: CoronaTestType) -> CoronaTest? {
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

	}

	// This function is responsible to register a PCR test from TeleTAN
	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping (Result<Void, CoronaTestServiceError>) -> Void
	) {

	}
	
	func registerPCRTestAndGetResult(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {

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

	}
	
	func reregister(coronaTest: CoronaTest) {

	}

	func updateTestResults(force: Bool, presentNotification: Bool, completion: @escaping VoidResultHandler) {

	}

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

	func removeTest(_ coronaTestType: CoronaTestType) {

	}

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType) {

	}

	func updatePublishersFromStore() {

	}

	func migrate() {

	}
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		return nil
	}

	#if DEBUG

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		return nil
	}

	#endif

	// MARK: - Internal

	var onUpdateTestResult: (
		_ coronaTestType: CoronaTestType,
		_ force: Bool,
		_ presentNotification: Bool
	) -> Void = { _, _, _ in }

	var onMoveTestToBin: (
		_ coronaTestType: CoronaTestType
	) -> Void = { _ in }

	var updateTestResultResult: Result<TestResult, CoronaTestServiceError>?
	var getSubmissionTANResult: Result<String, CoronaTestServiceError>?

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
