//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable
import CertLogic

enum CLLServiceError: Error {
	
}

enum DCCWalletInfoAccessError: Error {
	case failedFunctionsEvaluation(Error)
}

protocol CCLServable {
	
	func updateConfiguration(completion: (Swift.Result<Void, CLLServiceError>) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func evaluateFunctionWithDefaultValues<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T
	
	var configurationDidChange: PassthroughSubject<Bool, Never> { get }

}

class CLLService: CCLServable {
	
	// MARK: - Init
	
	init() { }
	
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
	
	func evaluateFunctionWithDefaultValues<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		let language = Locale.current.languageCode ?? "en"
		let parametersWithDefaults = CCLDefaultInput.addingTo(parameters: parameters, language: language)
		return try jsonFunctions.evaluateFunction(name: name, parameters: parametersWithDefaults)
	}
	
	var configurationDidChange = PassthroughSubject<Bool, Never>()

	// MARK: - Private
	
	let jsonFunctions: JsonFunctions = JsonFunctions()
	var boosterNotificationRules: [Rule] = [Rule]()
}
