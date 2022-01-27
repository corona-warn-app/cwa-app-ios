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
	case unsuppportedLocale
	case unknown(Error)
}

struct DCCWalletInfo {

}

protocol CCLServable {
	
	func updateConfiguration(completion: (Swift.Result<Void, CLLServiceError>) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Swift.Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func evaluateFunction<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T
	
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
		
		guard let language = Locale.current.languageCodeIfSupported else {
			return .failure(.unsuppportedLocale)
		}
		
		do {
			let getWalletInfoInput = GetWalletInfoInput.make(
				language: language,
				certificates: certificates,
				boosterNotificationRules: boosterNotificationRules
			)
			let walletInfo: DCCWalletInfo = try jsonFunctions.evaluateFunction(
				name: "getDCCWalletInfo",
				parameters: getWalletInfoInput
			)
			
			return .success(walletInfo)
		} catch {
			return .failure(.unknown(error))
		}
	}
	
	func evaluateFunction<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		return try JsonFunctions().evaluateFunction(name: name, parameters: parameters)
	}
	
	var configurationDidChange = PassthroughSubject<Bool, Never>()

	// MARK: - Private
	
	let jsonFunctions: JsonFunctions = JsonFunctions()
	var boosterNotificationRules: [Rule] = [Rule]()
}
