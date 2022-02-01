//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable
import CertLogic
import HealthCertificateToolkit

enum CLLDownloadError<T>: Error {
	case cached(T)
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

class CLLService: CCLServable {
	
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
			Log.error("Fialed to load boosterNotification rules from cache - init them empty", error: error)
			self.boosterNotificationRules = []
		}

		// cclConfigurations
		switch restServiceProvider.cached(cclConfigurationResource) {
		case let .success(configurations):
			self.cclConfigurations = configurations.cclConfigurations
		case let .failure(error):
			Log.error("Failed to read ccl configurations from cache - init empty", error: error)
			self.cclConfigurations = []
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
				// we got a new configuration - let update json functions
				configurations.forEach { configuration in
					self?.updateJsonFunctions(configuration)
				}
				self?.cclConfigurations = configurations
				configurationDidUpdate = true
			case let .failure(error):
				if case let .cached(configurations) = error {
					self?.cclConfigurations = configurations
					configurationDidUpdate = false
				}
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
			case let .failure(error):
				if case let .cached(rules) = error {
					self?.boosterNotificationRules = rules
					boosterRulesDidUpdate = false
				}
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
				name: "getDCCWalletInfo",
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
	private var cclConfigurations: [CCLConfiguration]

	private func getConfigurations(
		completion: @escaping (Swift.Result<[CCLConfiguration], CLLDownloadError<[CCLConfiguration]>>) -> Void
	) {
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(receiveModel):
				let configurations = receiveModel.cclConfigurations
				if receiveModel.metaData.loadedFromCache {
					completion(.failure(.cached(configurations)))
				} else {
					completion(.success(configurations))
				}
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
		completion: @escaping (Swift.Result<[Rule], CLLDownloadError<[Rule]>>) -> Void
	) {
		restServiceProvider.load(boosterNotificationRulesResource) { result in
			switch result {
			case let .success(receiveModel):
				if receiveModel.metaData.loadedFromCache {
					completion(.failure(.cached(receiveModel.rules)))
				} else {
					completion(.success(receiveModel.rules))
				}
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
		_ configuration: CCLConfiguration
	) {
		configuration.functionDescriptor.forEach { [weak self] jsonFunctionDescriptor in
			self?.jsonFunctions.registerFunction(jsonFunctionDescriptor: jsonFunctionDescriptor)
		}
	}

}
