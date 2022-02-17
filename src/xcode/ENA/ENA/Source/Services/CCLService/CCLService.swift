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
	case cachedOrDefault
}

enum DCCWalletInfoAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

enum DCCAdmissionCheckScenariosAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

protocol CCLServable {

	var configurationVersion: String { get }
	
	var cclAdmissionCheckScenariosDisabled: Bool { get }
	
	func updateConfiguration(completion: @escaping (_ didChange: Bool) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate], with identifier: String?) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func dccAdmissionCheckScenarios() -> Swift.Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError>

	func evaluateFunctionWithDefaultValues<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T

}


struct CCLServiceMode: OptionSet {
	let rawValue: Int
	static let configuration = CCLServiceMode(rawValue: 1 << 0)
	static let boosterRules = CCLServiceMode(rawValue: 1 << 1)
}

class CCLService: CCLServable {

	// MARK: - Init

	/// for testing we need to inject:
	/// - cclServiceMode: to select updated operating mode
	/// - signatureVerifier: for fake CBOR Receive Resources to work
	init(
		_ restServiceProvider: RestServiceProviding,
		appConfiguration: AppConfigurationProviding,
		cclServiceMode: [CCLServiceMode] = [.configuration, .boosterRules],
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.restServiceProvider = restServiceProvider
		self.appConfiguration = appConfiguration
		self.cclServiceMode = cclServiceMode

		var cclConfigurationResource = CCLConfigurationResource()
		cclConfigurationResource.receiveResource = CBORReceiveResource(signatureVerifier: signatureVerifier)
		self.cclConfigurationResource = cclConfigurationResource

		var boosterNotificationRulesResource = DCCRulesResource(ruleType: .boosterNotification)
		boosterNotificationRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: signatureVerifier)
		self.boosterNotificationRulesResource = boosterNotificationRulesResource

		// boosterNotificationRules
		self.boosterNotificationRules = []
		if cclServiceMode.contains(.boosterRules) {
			switch restServiceProvider.cached(boosterNotificationRulesResource) {
			case let .success(rules):
				self.boosterNotificationRules = rules.rules
			case let .failure(error):
				Log.error("Failed to load boosterNotification rules from cache - init them empty", error: error)
				self.boosterNotificationRules = []
			}
		}

		// cclConfigurations
		self.cclConfigurations = []
		if cclServiceMode.contains(.configuration) {
			switch restServiceProvider.cached(cclConfigurationResource) {
			case let .success(configurations):
				self.cclConfigurations = configurations.cclConfigurations
				self.updateJsonFunctions(configurations.cclConfigurations)
			case let .failure(error):
				Log.error("Failed to read ccl configurations from cache - init empty", error: error)
				self.updateJsonFunctions([])
			}
		}
	}
	
	// MARK: - Protocol CCLServable

	var configurationVersion: String {
		return cclConfigurations
			.sorted { $0.identifier < $1.identifier }
			.map { $0.version }
			.joined(separator: ", ")
	}

	var cclAdmissionCheckScenariosDisabled: Bool {
		return self.appConfiguration.featureProvider.boolValue(for: .cclAdmissionCheckScenariosDisabled)
	}
	
	func updateConfiguration(
		completion: @escaping (_ didChange: Bool) -> Void
	) {
		// trigger both downloads, if one was updated notify caller in result

		let dispatchGroup = DispatchGroup()

		var configurationDidUpdate: Bool = false
		var boosterRulesDidUpdate: Bool = false

		// lookup configuration updates
		if cclServiceMode.contains(.configuration) {
			dispatchGroup.enter()
			getConfigurations { [weak self] result in
				defer {
					dispatchGroup.leave()
				}

				switch result {
				case let .success(configurations):
					self?.cclConfigurations = configurations
					self?.updateJsonFunctions(configurations)
					configurationDidUpdate = true
				case .failure(let error):
					Log.error("CCLConfiguration might be loaded from the cache - skip this error", error: error)
				}
			}
		}

		// lookup booster notification rules updates
		if cclServiceMode.contains(.boosterRules) {
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
		}

		dispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) {
			completion( configurationDidUpdate || boosterRulesDidUpdate )
		}
	}
	
	func dccAdmissionCheckScenarios() -> Swift.Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError> {
		let getAdmissionCheckScenariosInput = GetAdmissionCheckScenariosInput.make()
		
		do {
			let admissionCheckScenarios: DCCAdmissionCheckScenarios = try jsonFunctions.evaluateFunction(
				name: "getDccAdmissionCheckScenarios",
				parameters: getAdmissionCheckScenariosInput
			)
			
			return .success(admissionCheckScenarios)
		} catch {
			return .failure(.failedFunctionsEvaluation(error))
		}
	}
	
	func dccWalletInfo(
		for certificates: [DCCWalletCertificate],
		with identifer: String? = ""
	) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		let getWalletInfoInput = GetWalletInfoInput.make(
			certificates: certificates,
			boosterNotificationRules: boosterNotificationRules,
			identifier: identifer
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
	private let appConfiguration: AppConfigurationProviding

	private let jsonFunctions: JsonFunctions = JsonFunctions()

	private let cclConfigurationResource: CCLConfigurationResource
	private let boosterNotificationRulesResource: DCCRulesResource

	private let cclServiceMode: [CCLServiceMode]

	private var boosterNotificationRules: [Rule]
	private var cclConfigurations: [CCLConfiguration]

	private func getConfigurations(
		completion: @escaping (Swift.Result<[CCLConfiguration], CCLDownloadError>) -> Void
	) {
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(receiveModel):
				guard !receiveModel.metaData.loadedFromCache,
					  !receiveModel.metaData.loadedFromDefault else {
					completion(.failure(.cachedOrDefault))
					return
				}
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
				guard !receiveModel.metaData.loadedFromCache,
					  !receiveModel.metaData.loadedFromDefault  else {
					completion(.failure(.cachedOrDefault))
					return
				}
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
