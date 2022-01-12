//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ValidationOnboardedCountriesResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false
	) {
		self.locator = .validationOnboardedCountries(isFake: isFake)
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ValidationOnboardedCountriesModel>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ValidationOnboardedCountriesModel>
	typealias CustomError = Error

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationOnboardedCountriesModel>

	// swiftlint:disable cyclomatic_complexity
	func customError(for error: ServiceError<ValidationOnboardedCountriesError>) -> ValidationOnboardedCountriesError? {
		switch error {
		case .resourceError:
			return .VS_ID_PARSE_ERR
		case .transportationError:
			return .ONBOARDED_COUNTRIES_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400...499):
				return .VS_ID_CLIENT_ERR
			case (500...599):
				return .VS_ID_SERVER_ERR
			default:
				return nil
			}
		default:
			return nil
		}
	}
}

enum ValidationOnboardedCountriesError: LocalizedError {
	
	case ONBOARDED_COUNTRIES_CLIENT_ERROR
	case ONBOARDED_COUNTRIES_DECODING_ERROR(RuleValidationError)
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
