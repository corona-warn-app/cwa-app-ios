////
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import CommonCrypto.CommonHMAC

enum CheckinDecryptionError: Error {
	case messageAuthenticationCodeMissmatch
	case decryptionFailed(CBCEncryptionError)
	case checkInRecordDecodingFailed
}

struct CheckinEncryptionResult {
	let encryptedCheckInRecord: Data
	let initializationVector: Data
	let messageAuthenticationCode: Data
}

enum CheckinEncryptionError: Error {
	case randomBytesCreationFailed
	case checkInRecordEncodingFailed
	case encryptionFailed(CBCEncryptionError)
	case hmacCreationFailed
}

protocol CheckinEncrypting {
	func decrypt(
		locationId: Data, // `location id` as byte sequence
		encryptedCheckinRecord: Data, // `encrypted CheckInRecord` as byte sequence
		initializationVector: Data, // `iv` (initialization vector) as byte sequence
		messageAuthenticationCode: Data // `mac` (message authentication code) as byte sequence
	) -> Result<SAP_Internal_Pt_CheckInRecord, CheckinDecryptionError>

	func encrypt(
		locationId: Data, // `location id` as byte sequence
		startInterval: Int, // start interval number` as integer
		endInterval: Int, // `end interval number` as integer
		riskLevel: Int, // `transmission risk level` as integer
		initializationVector: Data? // (initialization vector) as byte sequence (for testing purposes)
	) -> Result<CheckinEncryptionResult, CheckinEncryptionError>
}

struct CheckinEncryption: CheckinEncrypting {

	// MARK: - Protocol CheckinEncrypting

	func decrypt(
		locationId: Data, // `location id` as byte sequence
		encryptedCheckinRecord: Data, // `encrypted CheckInRecord` as byte sequence
		initializationVector: Data, // `iv` (initialization vector) as byte sequence
		messageAuthenticationCode: Data // `mac` (message authentication code) as byte sequence
	) -> Result<SAP_Internal_Pt_CheckInRecord, CheckinDecryptionError> {

		// Determine `recalculated mac`
		let recalculatedMac = self.messageAuthenticationCode(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: initializationVector
		)

		// Compare mac: if `recalculated mac` does not equal `mac`, the record has been tampered with and decryption shall fail.
		if messageAuthenticationCode != recalculatedMac {
			return .failure(.messageAuthenticationCodeMissmatch)
		}

		// Determine `encryption key`
		let encryptionKey = self.encryptionKey(for: locationId)

		// Create `CheckInRecord`: the `encrypted CheckInRecord` shall be decrypted
		let cbcEncryption = CBCEncryption(
			encryptionKey: encryptionKey,
			initializationVector: initializationVector
		)
		let decryptionResult = cbcEncryption.decrypt(data: encryptedCheckinRecord)

		guard case let .success(checkinRecordData) = decryptionResult else {
			if case let .failure(error) = decryptionResult {
				return .failure(.decryptionFailed(error))
			}
			fatalError("Success and failure where handled, this part should never be reaached.")
		}

		// Parse `CheckInRecord`: the `CheckInRecord` shall be parsed as [Protocol Buffer message CheckInRecord]
		guard let checkinRecord = try? SAP_Internal_Pt_CheckInRecord(serializedData: checkinRecordData) else {
			return .failure(.checkInRecordDecodingFailed)
		}

		return .success(checkinRecord)
	}

	func encrypt(
		locationId: Data, // `location id` as byte sequence
		startInterval: Int, // start interval number` as integer
		endInterval: Int, // `end interval number` as integer
		riskLevel: Int, // `transmission risk level` as integer
		initializationVector: Data? = nil // (initialization vector) as byte sequence (for testing purposes)
	) -> Result<CheckinEncryptionResult, CheckinEncryptionError> {

		// Determine `period`: the `period` shall be determined as `end interval number - start interval number`
		let period = endInterval - startInterval

		// Create `CheckInRecord`: the `CheckInRecord` shall be created as the byte representation of a [Protocol Buffer message CheckInRecord]
		var checkinRecord = SAP_Internal_Pt_CheckInRecord()
		checkinRecord.startIntervalNumber = UInt32(startInterval)
		checkinRecord.period = UInt32(period)
		checkinRecord.transmissionRiskLevel = UInt32(riskLevel)

		guard let checkinRecordData = try? checkinRecord.serializedData() else {
			return .failure(.checkInRecordEncodingFailed)
		}

		// Determine `encryption key`: the `encryption key` shall be determined
		let encryptionKey = self.encryptionKey(for: locationId)

		// Determine random `iv`: the initialization vector `iv` shall be determined as a secure random sequence of 32 bytes.
		guard let randomInitializationVector = randomBytes(length: 16) else {
			return .failure(.randomBytesCreationFailed)
		}
		let finalInitializationVector = initializationVector ?? randomInitializationVector


		// Create `encrypted CheckInRecord`: the `CheckInRecord` shall be encrypted
		let cbcEncryption = CBCEncryption(
			encryptionKey: encryptionKey,
			initializationVector: finalInitializationVector
		)
		let encryptionResult = cbcEncryption.encrypt(data: checkinRecordData)

		guard case let .success(encryptedCheckinData) = encryptionResult else {
			if case let .failure(error) = encryptionResult {
				return .failure(.encryptionFailed(error))
			}
			fatalError("Success and failure where handled, this part should never be reached.")
		}

		// Determine `mac`: the `mac` (message authentication code) shall be determined as the HMAC-SHA256
		guard let messageAuthenticationCode = messageAuthenticationCode(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinData,
			initializationVector: finalInitializationVector
		) else {
			return .failure(.hmacCreationFailed)
		}

		let finalEncryptionResult = CheckinEncryptionResult(
			encryptedCheckInRecord: encryptedCheckinData,
			initializationVector: finalInitializationVector,
			messageAuthenticationCode: messageAuthenticationCode
		)

		return .success(finalEncryptionResult)
	}

	func hmac(data: Data, key: Data) -> Data? {
		let dataLength = data.count
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: dataLength)
		defer { result.deallocate() }

		let success = data.withUnsafeBytes { dataPointer -> Bool in
			guard let dataPointerAddress = dataPointer.baseAddress else {
				Log.error("Could not access base address.", log: .checkin)
				return false
			}

			return key.withUnsafeBytes { keyPointer -> Bool in
				guard let keyPointerAddress = keyPointer.baseAddress else {
					Log.error("Could not access base address.", log: .checkin)
					return false
				}
				CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyPointerAddress, key.count, dataPointerAddress, dataLength, result)
				return true
			}
		}

		if success {
			let resultData = Data(bytes: result, count: 32)
			return resultData
		} else {
			return nil
		}
	}

	// MARK: - Private

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

	// Determine `mac`: the `mac` (message authentication code) shall be determined as the HMAC-SHA256
	private func messageAuthenticationCode(
		locationId: Data,
		encryptedCheckinRecord: Data,
		initializationVector: Data
	) -> Data? {

		let key = messageAuthenticationCodeKey(for: locationId)
		let data = initializationVector + encryptedCheckinRecord
		return hmac(data: data, key: key)
	}

	private func randomBytes(length: Int) -> Data? {
		var randomData = Data(count: length)

		let result: Int32? = randomData.withUnsafeMutableBytes {
			guard let baseAddress = $0.baseAddress else {
				Log.error("Could not access base address.", log: .checkin)
				return nil
			}
			return SecRandomCopyBytes(kSecRandomDefault, length, baseAddress)
		}
		if let result = result, result == errSecSuccess {
			return randomData
		} else {
			Log.error("Failed to generate random bytes.", log: .checkin)
			return nil
		}
	}
}
