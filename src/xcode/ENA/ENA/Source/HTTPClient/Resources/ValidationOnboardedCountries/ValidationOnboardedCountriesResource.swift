//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ValidationOnboardedCountriesResource: Resource {
	
	// MARK: - Init
	
	init(
		isFake: Bool = false,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .validationOnboardedCountries(isFake: isFake)
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ValidationOnboardedCountriesReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ValidationOnboardedCountriesReceiveModel>
	typealias CustomError = ValidationOnboardedCountriesError

	let trustEvaluation: TrustEvaluating
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationOnboardedCountriesReceiveModel>


	func customError(
		for error: ServiceError<ValidationOnboardedCountriesError>,
		responseBody: Data? = nil
	) -> ValidationOnboardedCountriesError? {
		switch error {
		case .transportationError:
			return .ONBOARDED_COUNTRIES_NO_NETWORK
		case .unexpectedServerError(let statusCode):
					switch statusCode {
					case (400...499):
						return .ONBOARDED_COUNTRIES_CLIENT_ERROR
					default:
						return .ONBOARDED_COUNTRIES_SERVER_ERROR
					}
		case let .resourceError(rError):
			return handleResourceError(rError)
		default:
			return nil
		}
	}
	
	// MARK: - Private
	
	private func handleResourceError(_ error: ResourceError?) -> ValidationOnboardedCountriesError? {
		guard let resourceError = error else {
			return nil
		}
		
		switch resourceError {
			
		case .missingData, .packageCreation:
			return .ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING
		case let .decoding(decodingError):
			return .ONBOARDED_COUNTRIES_DECODING_ERROR(decodingError)
		case .signatureVerification:
			return .ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID
		case .missingEtag:
			return .ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR
		case .missingCache:
			return .ONBOARDED_COUNTRIES_MISSING_CACHE
		default:
			return nil
		}
		
	}
}

enum ValidationOnboardedCountriesError: LocalizedError {
	
	case ONBOARDED_COUNTRIES_CLIENT_ERROR
	case ONBOARDED_COUNTRIES_DECODING_ERROR(ModelDecodingError)
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID
	case ONBOARDED_COUNTRIES_SERVER_ERROR
	case ONBOARDED_COUNTRIES_MISSING_CACHE
	case ONBOARDED_COUNTRIES_NO_NETWORK

	var errorDescription: String? {
		switch self {
		case .ONBOARDED_COUNTRIES_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_CLIENT_ERROR)"
		case let .ONBOARDED_COUNTRIES_DECODING_ERROR(error):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_DECODING_ERROR - \(error)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .ONBOARDED_COUNTRIES_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_SERVER_ERROR)"
		case .ONBOARDED_COUNTRIES_MISSING_CACHE:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_MISSING_CACHE)"
		case .ONBOARDED_COUNTRIES_NO_NETWORK:
			return "\(AppStrings.HealthCertificate.Validation.Error.noNetwork) (NO_NETWORK)"
		}
	}
}
