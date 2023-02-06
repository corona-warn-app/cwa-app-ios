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

enum StatusTabNoticeAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

protocol CCLServable {

	var shouldShowNoticeTile: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	
	var configurationVersion: String { get }
	
	var dccAdmissionCheckScenariosEnabled: Bool { get }
	
	func setup(
		signatureVerifier: SignatureVerification,
		cclConfigurationResource: CCLConfigurationResource,
		completion: @escaping () -> Void
	)
	
	func updateConfiguration(completion: @escaping (_ didChange: Bool) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate], with identifier: String?) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func dccAdmissionCheckScenarios() -> Swift.Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError>

	func statusTabNotice() -> Swift.Result<StatusTabNotice, StatusTabNoticeAccessError>
	
	func evaluateFunctionWithDefaultValues<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T

}

extension CCLServable {
	func setup(
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		cclConfigurationResource: CCLConfigurationResource = CCLConfigurationResource(),
		completion: @escaping () -> Void
	) {
		self.setup(
			signatureVerifier: signatureVerifier,
			cclConfigurationResource: cclConfigurationResource,
			completion: completion
		)
	}
}

struct CCLServiceMode: OptionSet {
	let rawValue: Int
	static let configuration = CCLServiceMode(rawValue: 1 << 0)
	static let boosterRules = CCLServiceMode(rawValue: 1 << 1)
	static let invalidationRules = CCLServiceMode(rawValue: 1 << 2)
}

class CCLService: CCLServable {

	// MARK: - Init

	/// for testing we need to inject:
	/// - cclServiceMode: to select updated operating mode
	/// - signatureVerifier: for fake CBOR Receive Resources to work
	init(
		_ restServiceProvider: RestServiceProviding,
		store: CCLStoring,
		appConfiguration: AppConfigurationProviding,
		cclServiceMode: [CCLServiceMode] = [.configuration, .boosterRules, .invalidationRules]
	) {
		self.restServiceProvider = restServiceProvider
		self.store = store
		self.appConfiguration = appConfiguration
		self.cclServiceMode = cclServiceMode
	}

	// MARK: - Protocol CCLServable
	
	var shouldShowNoticeTile = CurrentValueSubject<Bool, Never>(false)
	
	var configurationVersion: String = ""

	var dccAdmissionCheckScenariosEnabled: Bool {
		#if DEBUG
		if isUITesting && LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled.boolValue {
			return true
		}
		#endif
		
		return appConfiguration.featureProvider.boolValue(for: .dccAdmissionCheckScenariosEnabled)
	}
    
	func setup(
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		cclConfigurationResource: CCLConfigurationResource = CCLConfigurationResource(),
		completion: @escaping () -> Void
	) {
		setupQueue.async { [weak self] in
			guard let self = self else {
				completion()
				return
			}

			guard !self.isSetUp else {
				completion()
				return
			}
			
			self.setupBoosterNotificationRules(signatureVerifier: signatureVerifier)
			self.setupInvalidationRules(signatureVerifier: signatureVerifier)
			self.setupCCLConfigurations(
				signatureVerifier: signatureVerifier,
				cclConfigurationResource: cclConfigurationResource
			)
			
			self.isSetUp = true

			completion()
		}
	}
	
	// swiftlint:disable:next cyclomatic_complexity
	func updateConfiguration(
		completion: @escaping (_ didChange: Bool) -> Void
	) {
		// trigger the 3 downloads, if one was updated notify caller in result

		let dispatchGroup = DispatchGroup()

		var configurationDidUpdate: Bool = false
		var boosterRulesDidUpdate: Bool = false
		var invalidationRulesDidUpdate: Bool = false
		
		let result = statusTabNotice()
		switch result {
		case .success(let statusTabNotice):
			shouldShowNoticeTile.value = statusTabNotice.visible
		case .failure:
			shouldShowNoticeTile.value = false
		}
		
		// lookup configuration updates
		if cclServiceMode.contains(.configuration) {
			dispatchGroup.enter()
			getConfigurations { [weak self] result in
				defer {
					dispatchGroup.leave()
				}

				switch result {
				case let .success(configurations):
					self?.replaceCCLConfigurationsIfNeeded(with: configurations)
					configurationDidUpdate = true
				case .failure(let error):
					Log.error("CCLConfiguration might be loaded from the cache - skip this error", error: error)
				}
			}
		}

		// lookup booster notification rules updates
		if cclServiceMode.contains(.boosterRules) {
			dispatchGroup.enter()
			getDCCRules(for: boosterNotificationRulesResource) { [weak self] result in
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
		if cclServiceMode.contains(.invalidationRules) {
			dispatchGroup.enter()
			getDCCRules(for: invalidationRulesResource) { [weak self] result in
				defer {
					dispatchGroup.leave()
				}
				
				switch result {
				case let .success(rules):
					self?.invalidationRules = rules
					invalidationRulesDidUpdate = true
				case .failure:
					Log.error("Invalidation Rules might be loaded from the cache - skip this error")
				}
			}
		}
		dispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) {
			completion( configurationDidUpdate || boosterRulesDidUpdate || invalidationRulesDidUpdate  )
		}
	}
	
	func statusTabNotice() -> Swift.Result<StatusTabNotice, StatusTabNoticeAccessError> {
		#if DEBUG
		if isUITesting {
			return .success(mockStatusTabNotice)
		}
		#endif
		
		let getStatusTabNoticeInput = GetStatusTabNoticeInput.make()
		
		do {
			let statusTabNotice: StatusTabNotice = try jsonFunctions.evaluateFunction(
				name: "getStatusTabNotice",
				parameters: getStatusTabNoticeInput
			)
			
			return .success(statusTabNotice)
		} catch {
			return .failure(.failedFunctionsEvaluation(error))
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
			invalidationRules: invalidationRules,
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
	
	private let setupQueue = DispatchQueue(label: "com.sap.CCLService.setup")

	private let restServiceProvider: RestServiceProviding
	private let appConfiguration: AppConfigurationProviding

	private var jsonFunctions: JsonFunctions = JsonFunctions()

	private lazy var cclConfigurationResource: CCLConfigurationResource = CCLConfigurationResource()
	private lazy var boosterNotificationRulesResource: DCCRulesResource = DCCRulesResource(
		ruleType: .boosterNotification,
		restServiceType: .caching(
			Set<CacheUsePolicy>([.loadOnlyOnceADay])
		)
	)
	private lazy var invalidationRulesResource: DCCRulesResource = DCCRulesResource(
		ruleType: .invalidation,
		restServiceType: .caching(
			Set<CacheUsePolicy>([.loadOnlyOnceADay])
		)
	)

	private let cclServiceMode: [CCLServiceMode]
	private let store: CCLStoring

	private var boosterNotificationRules = [Rule]()
	private var invalidationRules = [Rule]()
	private var isSetUp = false
	
	#if DEBUG
	private var mockStatusTabNotice: StatusTabNotice {
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Betriebsende"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Der Betrieb der Corona-Warn-App wird am xx.xx.xxxx eingestellt."],
			parameters: []
		)
		
		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Sie erhalten dann keine Warnungen mehr über Risiko-begegnungen und können selbst andere nicht mehr warnen. Sie können keine Tests mehr registrieren und erhalten keine Testergebnisse mehr über die App. Auf Ihre Zertifikate und das Kontakt-Tagebuch haben Sie weiterhin Zugriff. Allerdings können Sie keine neuen Zertifikate mehr hinzufügen."],
			parameters: []
		)
		
		let faqText = "Mehr Informationen finden Sie in den FAQ."

		return StatusTabNotice(visible: true, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: faqText)
	}
	
	private var mockDCCAdmissionCheckScenarios: DCCAdmissionCheckScenarios {
		let statusTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Regelungen für:"],
			parameters: []
		)
		
		let buttonTitle = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "keine Auswahl"],
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
	
	private func setupBoosterNotificationRules(signatureVerifier: SignatureVerification) {
		self.boosterNotificationRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: signatureVerifier)

		// boosterNotificationRules
		if self.cclServiceMode.contains(.boosterRules) {
			self.restServiceProvider.cached(self.boosterNotificationRulesResource, { [weak self] result in
				switch result {
				case let .success(rules):
					self?.boosterNotificationRules = rules.rules
				case let .failure(error):
					Log.error("Failed to load boosterNotification rules from cache - init them empty", error: error)
					self?.boosterNotificationRules = []
				}
			})
		}
	}
	
	private func setupInvalidationRules(signatureVerifier: SignatureVerification) {
		self.invalidationRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: signatureVerifier)
		
		// InvalidationRules
		if self.cclServiceMode.contains(.invalidationRules) {
			self.restServiceProvider.cached(self.invalidationRulesResource, { [weak self] result in
				switch result {
				case let .success(rules):
					self?.invalidationRules = rules.rules
				case let .failure(error):
					Log.error("Failed to load invalidation rules from cache - init them empty", error: error)
					self?.invalidationRules = []
				}
			})
		}
	}
	
	private func setupCCLConfigurations(
		signatureVerifier: SignatureVerification,
		cclConfigurationResource: CCLConfigurationResource = CCLConfigurationResource()
	) {
		var mutableCclConfigurationResource = cclConfigurationResource
		mutableCclConfigurationResource.receiveResource = CBORReceiveResource(signatureVerifier: signatureVerifier)
		self.cclConfigurationResource = mutableCclConfigurationResource
		
		// cclConfigurations
		if self.cclServiceMode.contains(.configuration) {
			self.restServiceProvider.cached(mutableCclConfigurationResource, { [weak self] result in
				switch result {
				case let .success(configurations):
					self?.replaceCCLConfigurationsIfNeeded(with: configurations.cclConfigurations)
				case let .failure(error):
					Log.error("Failed to read ccl configurations from cache", error: error)
				}
			})
		}
	}

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
	
	private func getDCCRules(
		for resourceType: DCCRulesResource,
		completion: @escaping (Swift.Result<[Rule], CCLDownloadError>) -> Void
	) {
		restServiceProvider.load(resourceType) { result in
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
					completion(.failure(.custom(DCCDownloadRulesError.RULE_CLIENT_ERROR(resourceType.ruleType))))
				}
			}
		}
	}
	
	// this function checks the edge case if the new CCL updated version is lower than the previous version then we dont persist this new config and we keep the latest version
	// this case is only visible on Debug environment that is why have the #if !release
	// for release versions the latest downloaded CCL will always be persisted even if version number is lower
	private func replaceCCLConfigurationsIfNeeded(
		with newCCLConfigurations: [CCLConfiguration]
	) {
		var shouldReplaceCCLConfigurations = true

		#if !RELEASE
		let currentVersion = store.cclVersion ?? "0.0"
		let updatedVersion = newCCLConfigurations.first?.version ?? "0.0"
		let compareResult = currentVersion.compare(updatedVersion, options: .numeric)
		
		shouldReplaceCCLConfigurations = !(compareResult == .orderedDescending)
		#endif
		
		if shouldReplaceCCLConfigurations {
			replaceCCLConfigurations(with: newCCLConfigurations)
		} else {
			configurationVersion = currentVersion
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

		var registeredConfigurations = newCCLConfigurations

		/// Register functions from the default configurations as well, in case the default configurations contain (new) configurations not contained in the cached/fetched configurations
		
		if let defaultConfigurations = cclConfigurationResource.defaultModel?.cclConfigurations {
			for configuration in defaultConfigurations where !newCCLConfigurations.contains(where: { $0.identifier == configuration.identifier }) {
				registerJsonFunctions(from: configuration)
				registeredConfigurations.append(configuration)
			}
		}

		configurationVersion = registeredConfigurations
			.sorted { $0.identifier < $1.identifier }
			.map { $0.version }
			.joined(separator: ", ")
		self.store.cclVersion = configurationVersion
	}
	
	private func registerJsonFunctions(
		from configuration: CCLConfiguration
	) {
		for jsonFunctionDescriptor in configuration.functionDescriptors {
			jsonFunctions.registerFunction(jsonFunctionDescriptor: jsonFunctionDescriptor)
		}
	}

}
