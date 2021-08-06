////
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto.CommonHMAC

protocol CheckinEncrypting {
//	func decrypt()
//	func encrypt()
}

struct CheckinEncryption: CheckinEncrypting {

	func decrypt(
		locationId: Data,
		encryptedCheckinRecord: Data,
		initializationVector: Data,
		messageAuthenticationCode: Data
	) -> SAP_Internal_Pt_CheckInRecord? {

		let recalculatedMac = self.messageAuthenticationCode(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: initializationVector
		)

		// ToDo: Add error handling
		if messageAuthenticationCode != recalculatedMac {
			fatalError("")
		}

		let encryptionKey = encryptionKey(for: locationId)

		let aesEncryption = AESEncryption(encryptionKey: encryptionKey, initializationVector: initializationVector)

		let decryptionResult = aesEncryption.decrypt(data: encryptedCheckinRecord)

		guard case let .success(checkinRecordData) = decryptionResult else {
			return nil
		}

		guard let checkinRecord = try? SAP_Internal_Pt_CheckInRecord(serializedData: checkinRecordData) else {
			return nil
		}

		return checkinRecord
	}

	func encrypt() {
		
	}

	// Determine `MAC key`
	private func messageAuthenticationCodeKey(for locationId: Data) -> Data {
		guard let prefix = "CWA-MAC-KEY".data(using: .utf8) else {
			fatalError("Could not create mac key prefix.")
		}
		let macKeyData = prefix + locationId
		return macKeyData.sha256()
	}

	// Determine `encryption key`
	private func encryptionKey(for locationId: Data) -> Data {
		guard let prefix = "CWA-ENCRYPTION-KEY".data(using: .utf8) else {
			fatalError("Could not create encryption key prefix.")
		}
		let keyData = prefix + locationId
		return keyData.sha256()
	}

	private func messageAuthenticationCode(
		locationId: Data,
		encryptedCheckinRecord: Data,
		initializationVector: Data
	) -> Data {

		let key = messageAuthenticationCodeKey(for: locationId)
		let keyBase64 = key.base64EncodedString()
		let data = initializationVector + encryptedCheckinRecord
		return hmac(data: data, key: key)
	}

	private func hmac(data: Data, key: Data) -> Data {

		let dataLength = data.count
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: dataLength)

		data.withUnsafeBytes { dataPointer in
			key.withUnsafeBytes { keyPointer in
				CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyPointer, key.count, dataPointer, dataLength, result)
			}
		}

		return Data(bytes: result, count: dataLength)
	}
}
