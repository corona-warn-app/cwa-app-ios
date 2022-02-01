//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import jsonfunctions

@testable import ENA
import class CertLogic.Rule

struct FakeCCLService: CCLServable {

	// MARK: - Protocol CCLServable

	func updateConfiguration(completion: (Bool) -> Void) {
		completion(didChange)
	}

	func dccWalletInfo(for certificates: [DCCWalletCertificate]) -> Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		return dccWaltInfoResult
	}

	func evaluateFunction<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		guard let castedType = evaluationType as? T else {
			Log.info("Cast to T type failed")
			throw  jsonfunctions.ParseError.GenericError("Test failed to cast to type T")
		}
		return castedType
	}

	// MARK: - Internal

	var didChange: Bool = false
	var dccWaltInfoResult: Result<DCCWalletInfo, DCCWalletInfoAccessError> = .success(DCCWalletInfo.fake())
	var evaluationType: Any?

}
