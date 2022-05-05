//
// 🦠 Corona-Warn-App
//

import Foundation

enum KeySubmissionResourceError: LocalizedError, Equatable {
	case invalidPayloadOrHeaders
	case invalidTan
	case requestCouldNotBeBuilt
	case serverError(Int)
	
	var errorDescription: String? {
		switch self {
		case let .serverError(code):
			return "\(AppStrings.ExposureSubmissionError.other)\(code) \(AppStrings.ExposureSubmissionError.otherend)"
		case .invalidPayloadOrHeaders:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."
		case .invalidTan:
			return AppStrings.ExposureSubmissionError.invalidTan
		case .requestCouldNotBeBuilt:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."
		}
	}
}

struct KeySubmissionResource: Resource {

	init(
		payload: SubmissionPayload,
		isFake: Bool = false,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .keySubmission(payload: payload, isFake: isFake)
		self.type = .default
		self.receiveResource = EmptyReceiveResource()
		self.trustEvaluation = trustEvaluation
		
		self.sendResource = ProtobufSendResource(
			SAP_Internal_SubmissionPayload.with {
				$0.requestPadding = Self.getSubmissionPadding(for: payload.exposureKeys)
				$0.keys = payload.exposureKeys
				$0.checkIns = payload.checkins
				/// Consent needs always set to be true
				$0.consentToFederation = true
				$0.visitedCountries = payload.visitedCountries.map { $0.id }
				$0.submissionType = payload.submissionType
				$0.checkInProtectedReports = payload.checkinProtectedReports
			}
		)
	}
	
	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: ProtobufSendResource<SAP_Internal_SubmissionPayload>
	var receiveResource: EmptyReceiveResource

	func customError(for error: ServiceError<KeySubmissionResourceError>, responseBody: Data?) -> KeySubmissionResourceError? {
		switch error {
		case .invalidRequestError:
			return .requestCouldNotBeBuilt
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400:
				return .invalidPayloadOrHeaders
			case 403:
				return .invalidTan
			default:
				return .serverError(statusCode)
			}
		default:
			return nil
		}
	}
	
	/// This method recreates the request body of the submit keys request with a padding that fills up to resemble
	/// a request with 14 +`n` keys. Note that the `n`parameter is currently set to 0, but can change in the future
	/// when there will be support for 15 keys.
	private static func getSubmissionPadding(for keys: [SAP_External_Exposurenotification_TemporaryExposureKey]) -> Data {
		// This parameter denotes how many keys 14 + n have to be padded.
		let n = 0
		let paddedKeysAmount = 14 + n - keys.count
		guard paddedKeysAmount > 0 else { return Data() }
		guard let data = (String.getRandomString(of: 28 * paddedKeysAmount)).data(using: .ascii) else { return Data() }
		return data
	}
}
