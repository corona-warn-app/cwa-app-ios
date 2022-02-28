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
		if cclServiceMode.contains(.configuration) {
			switch restServiceProvider.cached(cclConfigurationResource) {
			case let .success(configurations):
				replaceCCLConfigurations(with: configurations.cclConfigurations)
			case let .failure(error):
				Log.error("Failed to read ccl configurations from cache", error: error)
			}
		}
	}
	
	// MARK: - Protocol CCLServable

	var configurationVersion: String = ""

	var cclAdmissionCheckScenariosDisabled: Bool {
		appConfiguration.featureProvider.boolValue(for: .cclAdmissionCheckScenariosDisabled)
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
					self?.replaceCCLConfigurations(with: configurations)
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
		#if DEBUG
		if isUITesting {
			return .success(mockDCCAdmissionCheckScenarios)
		}
		#endif

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

	private var jsonFunctions: JsonFunctions = JsonFunctions()

	private let cclConfigurationResource: CCLConfigurationResource
	private let boosterNotificationRulesResource: DCCRulesResource

	private let cclServiceMode: [CCLServiceMode]

	private var boosterNotificationRules: [Rule]

	#if DEBUG
	private var mockDCCAdmissionCheckScenarios: DCCAdmissionCheckScenarios {
		let statusTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Status für folgendes Bundesland"],
			parameters: []
		)
		
		let buttonTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Regeln des Bundes"],
			parameters: []
		)

		let countrySubtitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Regeln in Ihrem Bundesland können davon abweichen"],
			parameters: []
		)
		
		let bwTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Baden Württemberg"],
			parameters: []
		)
		
		let berlinTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Berlin"],
			parameters: []
		)
		
		let entireCountry = DCCScenarioSelectionItem(identifier: "DE", titleText: buttonTitle, subtitleText: countrySubtitle, enabled: true)
		let bw = DCCScenarioSelectionItem(identifier: "BW", titleText: bwTitle, subtitleText: nil, enabled: true)
		let berlin = DCCScenarioSelectionItem(identifier: "Berlin", titleText: berlinTitle, subtitleText: nil, enabled: true)
		
		return DCCAdmissionCheckScenarios(labelText: statusTitle, scenarioSelection: DCCScenarioSelection(titleText: buttonTitle, items: [entireCountry, bw, berlin]))
	}
	#endif

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

	private func replaceCCLConfigurations(
		with newCCLConfigurations: [CCLConfiguration]
	) {
		/// Reset registered functions by creating a new instance
		jsonFunctions = JsonFunctions()

		for configuration in newCCLConfigurations {
			registerJsonFunctions(from: configuration)
		}

		/// Register functions from the default configurations as well, in case the default configurations contain (new) configurations not contained in the cached/fetched configurations
		if let defaultConfigurations = cclConfigurationResource.defaultModel?.cclConfigurations {
			for configuration in defaultConfigurations where !newCCLConfigurations.contains(where: { $0.identifier == configuration.identifier }) {
				registerJsonFunctions(from: configuration)
			}
		}

		configurationVersion = newCCLConfigurations
			.sorted { $0.identifier < $1.identifier }
			.map { $0.version }
			.joined(separator: ", ")
	}

	private func registerJsonFunctions(
		from configuration: CCLConfiguration
	) {
		for jsonFunctionDescriptor in configuration.functionDescriptors {
			jsonFunctions.registerFunction(jsonFunctionDescriptor: jsonFunctionDescriptor)
		}
	}

}
