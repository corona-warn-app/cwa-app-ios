//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable
import CertLogic
import HealthCertificateToolkit

enum CCLDownloadError: Error {
	case missing
	case custom(Error)
}

enum DCCWalletInfoAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

protocol CCLServable {
	
	func updateConfiguration(completion: @escaping (_ didChange: Bool) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func evaluateFunctionWithDefaultValues<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T

}

class CCLService: CCLServable {
	
	// MARK: - Init
	
	init(
		_ restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider

		// boosterNotificationRules
		switch restServiceProvider.cached(boosterNotificationRulesResource) {
		case let .success(rules):
			self.boosterNotificationRules = rules.rules
		case let .failure(error):
			Log.error("Failed to load boosterNotification rules from cache - init them empty", error: error)
			self.boosterNotificationRules = []
		}

		// cclConfigurations
		switch restServiceProvider.cached(cclConfigurationResource) {
		case let .success(configurations):
			self.updateJsonFunctions(configurations.cclConfigurations)
		case let .failure(error):
			Log.error("Failed to read ccl configurations from cache - init empty", error: error)
			self.updateJsonFunctions([])
		}
	}
	
	// MARK: - Protocol CCLServable

	func updateConfiguration(
		completion: @escaping (_ didChange: Bool) -> Void
	) {
		// trigger both downloads, if one was updated notify caller in result

		let dispatchGroup = DispatchGroup()

		var configurationDidUpdate: Bool = false
		var boosterRulesDidUpdate: Bool = false

		// lookup configuration updates
		dispatchGroup.enter()
		getConfigurations { [weak self] result in
			defer {
				dispatchGroup.leave()
			}

			switch result {
			case let .success(configurations):
				self?.updateJsonFunctions(configurations)
				configurationDidUpdate = true
			case .failure:
				Log.error("CCLConfiguration might be loaded from the cache - skip this error")
			}
		}

		// lookup booster notification rules updates
		dispatchGroup.enter()
		getBoosterNotificationRules { [weak self] result in
			defer {
				dispatchGroup.leave()
			}

			switch result {
			case let .success(rules):
				self?.boosterNotificationRules = rules
				boosterRulesDidUpdate = true
			case .failure:
				Log.error("BoosterNotificationRules might be loaded from the cache - skip this error")
			}
		}

		dispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) {
			completion( configurationDidUpdate || boosterRulesDidUpdate )
		}
	}
	
	func dccWalletInfo(
		for certificates: [DCCWalletCertificate]
	) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		let getWalletInfoInput = GetWalletInfoInput.make(
			certificates: certificates,
			boosterNotificationRules: boosterNotificationRules
		)
		
		do {
			let walletInfo: DCCWalletInfo = try jsonFunctions.evaluateFunction(
				name: "getDccWalletInfo",
				parameters: getWalletInfoInput
			)
			return .success(walletInfo)
		} catch {
			return .failure(.failedFunctionsEvaluation(error))
		}
	}
	
	func evaluateFunctionWithDefaultValues<T>(
		name: String,
		parameters: [String: AnyDecodable]
	) throws -> T where T: Decodable {
		let parametersWithDefaults = CCLDefaultInput.addingTo(parameters: parameters)
		return try jsonFunctions.evaluateFunction(name: name, parameters: parametersWithDefaults)
	}

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let jsonFunctions: JsonFunctions = JsonFunctions()
	private let cclConfigurationResource = CCLConfigurationResource()
	private let boosterNotificationRulesResource = DCCRulesResource(ruleType: .boosterNotification)
	private var boosterNotificationRules: [Rule]

	private func getConfigurations(
		completion: @escaping (Swift.Result<[CCLConfiguration], CCLDownloadError>) -> Void
	) {
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(receiveModel):
				completion(.success(receiveModel.cclConfigurations))
			case let .failure(error):
				switch error {
				case .fakeResponse:
					completion(.success([]))
				default:
					completion(.failure(.missing))
				}
			}
		}
	}

	private func getBoosterNotificationRules(
		completion: @escaping (Swift.Result<[Rule], CCLDownloadError>) -> Void
	) {
		restServiceProvider.load(boosterNotificationRulesResource) { result in
			switch result {
			case let .success(receiveModel):
				completion(.success(receiveModel.rules))
			case let .failure(error):
				if case let .receivedResourceError(customError) = error {
					completion(.failure(.custom(customError)))
				} else {
					Log.error("Unhandled error \(error.localizedDescription)", log: .vaccination)
					completion(.failure(.custom(DCCDownloadRulesError.RULE_CLIENT_ERROR(.boosterNotification))))
				}
			}
		}
	}

	private func updateJsonFunctions(
		_ configurations: [CCLConfiguration]
	) {
		configurations.forEach { [weak self] configuration in
			configuration.functionDescriptors.forEach { jsonFunctionDescriptor in
				self?.jsonFunctions.registerFunction(jsonFunctionDescriptor: jsonFunctionDescriptor)
			}
		}
	}

}
