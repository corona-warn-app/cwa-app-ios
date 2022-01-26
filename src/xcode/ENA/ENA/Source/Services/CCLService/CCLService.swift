//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonfunctions
import OpenCombine
import AnyCodable

enum CLLServiceError: Error {
	
}

struct DCCWalletCertificate {
	
}

struct DCCWalletInfo {
	
}

enum DCCWalletInfoAccessError: Error {
	
}

protocol CCLServable {
	
	func updateConfiguration(completion: (Result<Void, CLLServiceError>) -> Void)
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Result<DCCWalletInfo, DCCWalletInfoAccessError>
	
	func evaluateFunction<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T
	
	var configurationDidChange: PassthroughSubject<Bool, Never> { get }

}

class CLLService: CCLServable {
	
	init() { }
	
	func updateConfiguration(completion: (Result<Void, CLLServiceError>) -> Void) {
		completion(.success(()))
	}
	
	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		return .success(DCCWalletInfo())
	}
	
	func evaluateFunction<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		return try JsonFunctions().evaluateFunction(name: name, parameters: parameters)
	}
	
	var configurationDidChange = PassthroughSubject<Bool, Never>()

}
