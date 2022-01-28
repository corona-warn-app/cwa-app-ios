//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable
import CertLogic

enum CLLServiceError: Error {
	case MissingConfiguration
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
		_ restServiceProvider: RestServiceProviding,
		rulesDownloadService: RulesDownloadServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
		self.rulesDownloadService = rulesDownloadService
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
	private let rulesDownloadService: RulesDownloadServiceProviding

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

}
