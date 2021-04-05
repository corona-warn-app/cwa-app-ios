//
// 🦠 Corona-Warn-App
//

import Foundation
import ZIPFoundation


extension Archive {

	func extractAppConfiguration() throws -> SAP_Internal_V2_ApplicationConfigurationIOS {
		guard let binEntry = self["export.bin"] else {
			throw FingerprintError.entryNotFound(entryID: "export.bin")
		}
//		guard let hashEntry = self["export.sha256"] else {
//			throw FingerprintError.entryNotFound(entryID: "export.sig")
//		}

		do {
			//let hash = try extractData(from: hashEntry)
			let bin = try extractData(from: binEntry)

			//let hashString = String(data: hash, encoding: .utf8)
			let config = try SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: bin)

			// we currently compare the raw bin instead of the deserialized object
//			guard /*config.fingerprint*/ bin.sha256String() == hashString else {
//				Log.error("Fingerprint mismatch", log: .localData)
//				throw FingerprintError.binaryNotValidated
//			}

			return config
		} catch {
			Log.error("Extraction error: \(error)", log: .localData, error: error)
			throw error
		}
	}
}

enum FingerprintError: Error {
	case binaryNotValidated
	case entryNotFound(entryID: String)
}

protocol Fingerprinting {
	var fingerprint: String { get }
}

extension SAP_Internal_V2_ApplicationConfigurationIOS: Fingerprinting {

	var fingerprint: String {
		do {
			let data = try serializedData()
			return data.sha256String()
		} catch {
			Log.error("Cannot fingerprint \(self)", log: .localData, error: error)
			return ""
		}
	}
}
