//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

class ExposureSubmissionCoordinatorModel {

	// MARK: - Init

	init(
		exposureSubmissionService: ExposureSubmissionService,
		coronaTestService: CoronaTestServiceProviding,
		srsService: SRSServiceProviding,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		eventProvider: EventProviding,
		recycleBin: RecycleBin
	) {
		self.exposureSubmissionService = exposureSubmissionService
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.coronaTestService = coronaTestService
		self.eventProvider = eventProvider
		self.recycleBin = recycleBin
		self.srsService = srsService
		// Try to load current country list initially to make it virtually impossible the user has to wait for it later.
		exposureSubmissionService.loadSupportedCountries { _ in
			// no op
		} onSuccess: { _ in
			Log.debug("[Coordinator] initial country list loaded", log: .riskDetection)
		}
	}

	// MARK: - Internal

	let exposureSubmissionService: ExposureSubmissionService
	let coronaTestService: CoronaTestServiceProviding
	let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	let eventProvider: EventProviding
	let recycleBin: RecycleBin
	let srsService: SRSServiceProviding
	
	var submissionTestType: SubmissionTestType?
	var markNewlyAddedCoronaTestAsUnseen: Bool = false
	var shouldShowSymptomsOnsetScreen = false

	var coronaTest: UserCoronaTest? {
		guard case let .registeredTest(coronaTestType) = submissionTestType, let coronaTestType = coronaTestType else {
			return nil
		}

		return coronaTestService.coronaTest(ofType: coronaTestType)
	}

	var coronaTestType: CoronaTestType? {
		guard case let .registeredTest(coronaTestType) = self.submissionTestType else {
			return nil
		}

		return coronaTestType
	}
	
	func shouldShowOverrideTestNotice(for coronaTestType: CoronaTestType) -> Bool {
		if let oldTest = coronaTestService.coronaTest(ofType: coronaTestType),
		   oldTest.testResult != .expired,
		   !(oldTest.type == .antigen && coronaTestService.antigenTestIsOutdated.value) {
			return true
		} else {
			return false
		}
	}

	func shouldShowTestCertificateScreen(with testRegistrationInformation: CoronaTestRegistrationInformation) -> Bool {
		switch testRegistrationInformation {
		case .pcr:
			return true
		case .rapidPCR(qrCodeInformation: let qrCodeInformation, qrCodeHash: _):
			return qrCodeInformation.certificateSupportedByPointOfCare ?? false
		case .antigen(qrCodeInformation: let qrCodeInformation, qrCodeHash: _):
			return qrCodeInformation.certificateSupportedByPointOfCare ?? false
		case .teleTAN:
			return false
		}
	}
	
	/// Handle the storing of the selected submission type (only SRS types!).
	/// - Parameter _ type: The selected submission type (SRS)
	func storeSelectedSRSSubmissionType(_ type: SRSSubmissionType) {
		submissionTestType = .srs(type)
	}

	func symptomsOptionSelected(
		_ selectedSymptomsOption: ExposureSubmissionSymptomsViewController.SymptomsOption
	) {
		switch selectedSymptomsOption {
		case .yes:
			shouldShowSymptomsOnsetScreen = true
		case .no:
			exposureSubmissionService.symptomsOnset = .nonSymptomatic
			shouldShowSymptomsOnsetScreen = false
		case .preferNotToSay:
			exposureSubmissionService.symptomsOnset = .noInformation
			shouldShowSymptomsOnsetScreen = false
		}
	}

	func symptomsOnsetOptionSelected(
		_ selectedSymptomsOnsetOption: ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption
	) {
		
		switch selectedSymptomsOnsetOption {
		case .exactDate(let date):
			guard let daysSinceOnset = Calendar.gregorian().dateComponents([.day], from: date, to: Date()).day else { fatalError("Getting days since onset from date failed") }
			exposureSubmissionService.symptomsOnset = .daysSinceOnset(daysSinceOnset)
		case .lastSevenDays:
			exposureSubmissionService.symptomsOnset = .lastSevenDays
		case .oneToTwoWeeksAgo:
			exposureSubmissionService.symptomsOnset = .oneToTwoWeeksAgo
		case .moreThanTwoWeeksAgo:
			exposureSubmissionService.symptomsOnset = .moreThanTwoWeeksAgo
		case .preferNotToSay:
			exposureSubmissionService.symptomsOnset = .symptomaticWithUnknownOnset
		}
	}

	func recycleBinItemToRestore(
		for testRegistrationInformation: CoronaTestRegistrationInformation
	) -> RecycleBinItem? {
		switch testRegistrationInformation {
		case .pcr(guid: _, qrCodeHash: let qrCodeHash),
			.antigen(qrCodeInformation: _, qrCodeHash: let qrCodeHash),
			.rapidPCR(qrCodeInformation: _, qrCodeHash: let qrCodeHash):
			return recycleBin.recycledItems.first {
				let recycledQRCodeHash: String
				if case .userCoronaTest(let coronaTest) = $0.item, let userQRCodeHash = coronaTest.qrCodeHash {
					recycledQRCodeHash = userQRCodeHash
				} else if case .familyMemberCoronaTest(let coronaTest) = $0.item {
					recycledQRCodeHash = coronaTest.qrCodeHash
				} else {
					return false
				}

				return recycledQRCodeHash == qrCodeHash
			}
		case .teleTAN:
			return nil
		}
	}

	func submitExposure(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionServiceError) -> Void
	) {
		guard case let .registeredTest(coronaTestType) = submissionTestType, let coronaTestType = coronaTestType else {
			onError(.preconditionError(.noCoronaTestTypeGiven))
			return
		}

		isLoading(true)

		exposureSubmissionService.submitExposure(coronaTestType: coronaTestType) { error in
			isLoading(false)

			switch error {

			// We continue the regular flow even if there are no keys collected.
			case .none, .preconditionError(.noKeysCollected):
				onSuccess()

			// We don't show an error if the submission consent was not given, because we assume that the submission already happened in the background.
			case .preconditionError(.noSubmissionConsent):
				Log.info("Consent Not Given", log: .ui)
				onSuccess()

			case .some(let error):
				Log.error("error: \(error.localizedDescription)", log: .api)
				onError(error)
			}
		}
	}

	func submitSRSExposure(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionServiceError) -> Void
	) {
		guard case let .srs(srsSubmissionType) = submissionTestType else {
			return
		}
		isLoading(true)
		srsService.authenticate(completion: { [weak self] result in
			guard let self = self else { return }
			isLoading(false)
			switch result {
			case .success(let srsOTP):
				self.exposureSubmissionService.submitSRSExposure(
					submissionType: srsSubmissionType,
					srsOTP: srsOTP
				) { error in
					
					switch error {
						
						// We continue the regular flow even if there are no keys collected.
					case .none, .preconditionError(.noKeysCollected):
						onSuccess()
						
						// We don't show an error if the submission consent was not given, because we assume that the submission already happened in the background.
					case .preconditionError(.noSubmissionConsent):
						Log.info("Consent Not Given", log: .ui)
						onSuccess()
						
					case .some(let error):
						Log.error("error: \(error.localizedDescription)", log: .api)
						onError(error)
					}
				}
			case .failure(let srsError):
				onError(.srsError(srsError))
				Log.debug(srsError.description, log: .ppac)
			}
			
		})
	}

	// swiftlint:disable cyclomatic_complexity
	func registerTestAndGetResult(
		for registrationInformation: CoronaTestRegistrationInformation,
		isSubmissionConsentGiven: Bool,
		certificateConsent: TestCertificateConsent,
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping (TestResult) -> Void,
		onError: @escaping (CoronaTestServiceError) -> Void
	) {
		isLoading(true)
		// QR code test fetch
		switch registrationInformation {
		case let .pcr(guid: guid, qrCodeHash: qrCodeHash):
			coronaTestService.registerPCRTestAndGetResult(
				guid: guid,
				qrCodeHash: qrCodeHash,
				isSubmissionConsentGiven: isSubmissionConsentGiven,
				markAsUnseen: markNewlyAddedCoronaTestAsUnseen,
				certificateConsent: certificateConsent,
				completion: { result in
					isLoading(false)
					
					switch result {
					case let .failure(error):
						onError(error)
					case let .success(testResult):
						onSuccess(testResult)
					}
				}
			)
		case let .antigen(qrCodeInformation: qrCodeInformation, qrCodeHash: qrCodeHash):
			coronaTestService.registerAntigenTestAndGetResult(
				with: qrCodeInformation.hash,
				qrCodeHash: qrCodeHash,
				pointOfCareConsentDate: qrCodeInformation.pointOfCareConsentDate,
				firstName: qrCodeInformation.firstName,
				lastName: qrCodeInformation.lastName,
				dateOfBirth: qrCodeInformation.dateOfBirthString,
				isSubmissionConsentGiven: isSubmissionConsentGiven,
				markAsUnseen: markNewlyAddedCoronaTestAsUnseen,
				certificateSupportedByPointOfCare: qrCodeInformation.certificateSupportedByPointOfCare ?? false,
				certificateConsent: certificateConsent,
				completion: { result in
					isLoading(false)
					
					switch result {
					case let .failure(error):
						onError(error)
					case let .success(testResult):
						onSuccess(testResult)
					}
				}
			)
		case let .rapidPCR(qrCodeInformation: qrCodeInformation, qrCodeHash: qrCodeHash):
			coronaTestService.registerRapidPCRTestAndGetResult(
				with: qrCodeInformation.hash,
				qrCodeHash: qrCodeHash,
				pointOfCareConsentDate: qrCodeInformation.pointOfCareConsentDate,
				firstName: qrCodeInformation.firstName,
				lastName: qrCodeInformation.lastName,
				dateOfBirth: qrCodeInformation.dateOfBirthString,
				isSubmissionConsentGiven: isSubmissionConsentGiven,
				markAsUnseen: markNewlyAddedCoronaTestAsUnseen,
				certificateSupportedByPointOfCare: qrCodeInformation.certificateSupportedByPointOfCare ?? false,
				certificateConsent: certificateConsent,
				completion: { result in
					isLoading(false)
					
					switch result {
					case let .failure(error):
						onError(error)
					case let .success(testResult):
						onSuccess(testResult)
					}
				}
			)
		case .teleTAN(let teleTAN):
			coronaTestService.registerPCRTestAndGetResult(
				teleTAN: teleTAN,
				isSubmissionConsentGiven: isSubmissionConsentGiven,
				completion: { result in
					isLoading(false)
					
					switch result {
					case let .failure(error):
						onError(error)
					case let .success(testResult):
						onSuccess(testResult)
					}
				}
			)
		}
	}

	func registerFamilyMemberTestAndGetResult(
		for displayName: String,
		registrationInformation: CoronaTestRegistrationInformation,
		certificateConsent: TestCertificateConsent,
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping (FamilyMemberCoronaTest) -> Void,
		onError: @escaping (CoronaTestServiceError) -> Void
	) {
		isLoading(true)
		// QR code test fetch
		switch registrationInformation {
		case let .pcr(guid: guid, qrCodeHash: qrCodeHash):
			familyMemberCoronaTestService.registerPCRTestAndGetResult(
					for: displayName,
					guid: guid,
					qrCodeHash: qrCodeHash,
					certificateConsent: certificateConsent,
					completion: { result in
						DispatchQueue.main.async {
							isLoading(false)

							switch result {
							case let .failure(error):
								onError(error)
							case let .success(testResult):
								onSuccess(testResult)
							}
						}
					}
			  )
		case let .antigen(qrCodeInformation: qrCodeInformation, qrCodeHash: qrCodeHash):
			familyMemberCoronaTestService.registerAntigenTestAndGetResult(
				   for: displayName,
				   with: qrCodeInformation.hash,
				   qrCodeHash: qrCodeHash,
				   pointOfCareConsentDate: qrCodeInformation.pointOfCareConsentDate,
				   certificateSupportedByPointOfCare: qrCodeInformation.certificateSupportedByPointOfCare ?? false,
				   certificateConsent: certificateConsent,
				   completion: { result in
					   isLoading(false)
					   
					   switch result {
					   case let .failure(error):
						   onError(error)
					   case let .success(testResult):
						   onSuccess(testResult)
					   }
				   }
			)
		case let .rapidPCR(qrCodeInformation: qrCodeInformation, qrCodeHash: qrCodeHash):
			familyMemberCoronaTestService.registerRapidPCRTestAndGetResult(
				   for: displayName,
				   with: qrCodeInformation.hash,
				   qrCodeHash: qrCodeHash,
				   pointOfCareConsentDate: qrCodeInformation.pointOfCareConsentDate,
				   certificateSupportedByPointOfCare: qrCodeInformation.certificateSupportedByPointOfCare ?? false,
				   certificateConsent: certificateConsent,
				   completion: { result in
					   isLoading(false)
					   
					   switch result {
					   case let .failure(error):
						   onError(error)
					   case let .success(testResult):
						   onSuccess(testResult)
					   }
				   }
			)
		case .teleTAN(tan: _):
			// we don't support type teleTAN for family members
			break
		}
	}
	
	func setSubmissionConsentGiven(_ isSubmissionConsentGiven: Bool) {
		switch submissionTestType {
		case .registeredTest(let coronaTestType):
			switch coronaTestType {
			case .pcr:
				coronaTestService.pcrTest.value?.isSubmissionConsentGiven = isSubmissionConsentGiven
			case .antigen:
				coronaTestService.antigenTest.value?.isSubmissionConsentGiven = isSubmissionConsentGiven
			case .none:
				fatalError("Cannot set submission consent, no corona test type is set")
			}
		case .srs:
			// we don't store the consent in case of SRS
			break
		case .none:
			fatalError("Cannot set submission consent, no corona test type is set")
		}
	}
}
