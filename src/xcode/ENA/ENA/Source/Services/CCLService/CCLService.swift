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

class CCLService: CCLServable {
	
	// MARK: - Init
	
	init() { }
	
	// MARK: - Protocol CCLServable

	func updateConfiguration(completion: (Swift.Result<Void, CLLServiceError>) -> Void) {
		completion(.success(()))
	}
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError> {
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
	
	func evaluateFunctionWithDefaultValues<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		let parametersWithDefaults = CCLDefaultInput.addingTo(parameters: parameters)
		return try jsonFunctions.evaluateFunction(name: name, parameters: parametersWithDefaults)
	}
	
	var configurationDidChange = PassthroughSubject<Bool, Never>()

	// MARK: - Private
	
	let jsonFunctions: JsonFunctions = JsonFunctions()
	var boosterNotificationRules: [Rule] = [Rule]()
}
