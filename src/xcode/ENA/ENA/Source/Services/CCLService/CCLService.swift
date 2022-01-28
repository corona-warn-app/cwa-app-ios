//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable
import CertLogic
import HealthCertificateToolkit

enum CLLServiceError: Error {
	case MissingConfiguration
	case BoosterRulesUpdateFailure
}

enum DCCWalletInfoAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

protocol CCLServable {
	
	func updateConfiguration(completion: (Swift.Result<Void, CLLServiceError>) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func evaluateFunction<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T
	
	var configurationDidChange: PassthroughSubject<Bool, Never> { get }

}

class CLLService: CCLServable {
	
	// MARK: - Init
	
	init(
		_ restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Protocol CCLServable

	func updateConfiguration(completion: (Swift.Result<Void, CLLServiceError>) -> Void) {
		completion(.success(()))
	}
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		let language = Locale.current.languageCode ?? "en"
		
		let getWalletInfoInput = GetWalletInfoInput.make(
			language: language,
			certificates: certificates,
			boosterNotificationRules: boosterNotificationRules
		)
		
		do {
			let walletInfo: DCCWalletInfo = try jsonFunctions.evaluateFunction(
				name: "getDCCWalletInfo",
				parameters: getWalletInfoInput
			)
			return .success(walletInfo)
		} catch {
			return .failure(.failedFunctionsEvaluation(error))
		}
	}
	
	func evaluateFunction<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		return try JsonFunctions().evaluateFunction(name: name, parameters: parameters)
	}
	
	var configurationDidChange = PassthroughSubject<Bool, Never>()

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding

	private let jsonFunctions: JsonFunctions = JsonFunctions()

	private var boosterNotificationRules: [Rule] = [Rule]()

	private func getLatestConfiguration(completion: @escaping (Swift.Result<Void, CLLServiceError>) -> Void) {
		let resource = CCLConfigurationResource()
		restServiceProvider.load(resource) { [weak self] result in
			switch result {
			case let .success(configuration):
				if !configuration.metaData.loadedFromCache {
					self?.configurationDidChange.send(true)
				}
			case let .failure(error):
				switch error {
				case .fakeResponse:
					completion(.success(()))
				default:
					completion(.failure(.MissingConfiguration))
				}
			}
		}
	}

	private func updateBoosterNotificationRules(
		ruleType: HealthCertificateValidationRuleType = .boosterNotification,
		completion: @escaping (Swift.Result<Void, DCCDownloadRulesError>) -> Void
	) {
		let resource = DCCRulesResource(ruleType: ruleType)
		restServiceProvider.load(resource) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case let .success(validationRulesModel):
					self?.boosterNotificationRules = validationRulesModel.rules
					completion(.success(()))
				case let .failure(error):
					if case let .receivedResourceError(customError) = error {
						completion(.failure(customError))
					} else {
						Log.error("Unhandled error \(error.localizedDescription)", log: .vaccination)
						completion(.failure(.RULE_CLIENT_ERROR(ruleType)))
					}
				}
			}
		}
	}

	private func updateJsonFunctions(_ configuration: CCLConfiguration) {
		configuration.functionDescriptor.forEach { [weak self] jsonFunctionDescriptor in
			self?.jsonFunctions.registerFunction(jsonFunctionDescriptor: jsonFunctionDescriptor)
		}
	}

}
