//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class StoreTests: CWATestCase {
	private var store: SecureStore!

	override func setUpWithError() throws {
		try super.setUpWithError()
		store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456")
	}

	func testResultReceivedTimeStamp_Success() {
		XCTAssertNil(store.testResultReceivedTimeStamp)
		store.testResultReceivedTimeStamp = Int64.max
		XCTAssertEqual(store.testResultReceivedTimeStamp, Int64.max)
		store.testResultReceivedTimeStamp = Int64.min
		XCTAssertEqual(store.testResultReceivedTimeStamp, Int64.min)
	}

	func testLastSuccessfulSubmitDiagnosisKeyTimestamp_Success() {
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.max
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.max)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.min
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.min)
	}

	func testRegistrationToken_Success() {
		XCTAssertNil(store.registrationToken)

		let token = UUID().description
		store.registrationToken = token
		XCTAssertEqual(store.registrationToken, token)
	}

	/// Reads a statically created db from version 1.0.0 into the app container and checks, whether all values from that version are still readable
	func testBackwardsCompatibility() throws {
		// swiftlint:disable:next force_unwrapping
		let testStoreSourceURL = Bundle(for: StoreTests.self).url(forResource: "testStore", withExtension: "sqlite")!

		let fileManager = FileManager.default
		let directoryURL = fileManager
			.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
			.appendingPathComponent("testDatabase")
		try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
		let testStoreTargetURL = directoryURL.appendingPathComponent("secureStore.sqlite")

		XCTAssertTrue(fileManager.fileExists(atPath: testStoreSourceURL.path))
		XCTAssertFalse(fileManager.fileExists(atPath: testStoreTargetURL.path))
		try fileManager.copyItem(at: testStoreSourceURL, to: testStoreTargetURL)

		let tmpStore: Store = try SecureStore(at: directoryURL, key: "12345678")

		// Prepare data
		let testTimeStamp: Int64 = 1466467200  // 21.06.2016
		let testDate1 = Date(timeIntervalSince1970: Double(testTimeStamp))

		XCTAssertTrue(tmpStore.isOnboarded)
		XCTAssertEqual(tmpStore.dateOfAcceptedPrivacyNotice?.description, testDate1.description)
		XCTAssertEqual(tmpStore.exposureActivationConsentAcceptTimestamp, testTimeStamp)
		XCTAssertTrue(tmpStore.exposureActivationConsentAccept)
	}
	
	func testDeviceTimeSettings_initalAfterInitialization() {
		XCTAssertEqual(store.deviceTimeCheckResult, .correct)
		XCTAssertFalse(store.wasDeviceTimeErrorShown)
		
		store.deviceTimeCheckResult = .incorrect
		store.wasDeviceTimeErrorShown = true
		
		XCTAssertEqual(store.deviceTimeCheckResult, .incorrect)
		XCTAssertTrue(store.wasDeviceTimeErrorShown)
	}

	func testValueToggles() throws {
		let store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456")

		let isOnboarded = store.isOnboarded
		store.isOnboarded.toggle()
		XCTAssertNotEqual(isOnboarded, store.isOnboarded)
	}

	func testBackupRestoration() throws {
		// prerequisite: clean state
		let keychain = try KeychainHelper()
		try keychain.clearInKeychain(key: SecureStore.encryptionKeyKeychainKey)

		// 1. create store and store db key in keychain
		let store = SecureStore(subDirectory: "test")
		XCTAssertFalse(store.isOnboarded)
		// user finished onboarding and used the app…
		store.isOnboarded.toggle()
		store.testGUID = UUID().uuidString

		guard let databaseKey = keychain.loadFromKeychain(key: SecureStore.encryptionKeyKeychainKey) else {
			XCTFail("expected a key!")
			return
		}

		// 2. restored with db key in keychain
		// This simulates iCloud keychain
		let restore = SecureStore(subDirectory: "test")
		XCTAssertTrue(restore.isOnboarded)
		XCTAssertEqual(restore.testGUID, store.testGUID)
		// still the same key?
		XCTAssertEqual(databaseKey, keychain.loadFromKeychain(key: SecureStore.encryptionKeyKeychainKey))

		// 3. db key in keychain 'changed' for some reason
		// swiftlint:disable:next force_unwrapping
		try keychain.saveToKeychain(key: SecureStore.encryptionKeyKeychainKey, data: "corrupted".data(using: .utf8)!)
		let restore2 = SecureStore(subDirectory: "test")
		// database reset?
		XCTAssertFalse(restore2.isOnboarded)
		XCTAssertEqual(restore2.testGUID, "") // init values…
		XCTAssertNotEqual(databaseKey, keychain.loadFromKeychain(key: SecureStore.encryptionKeyKeychainKey))

		// cleanup
		store.wipeAll(key: nil)
	}

	func testConfigCaching() throws {
		let store = SecureStore(subDirectory: "test")
		store.appConfigMetadata = nil
		XCTAssertNil(store.appConfigMetadata)

		let tag = "fake_\(Int.random(in: 100...999))"
		let config = CachingHTTPClientMock.staticAppConfig
		let appConfigMetadata = AppConfigMetadata(lastAppConfigETag: tag, lastAppConfigFetch: Date(), appConfig: config)
		
		store.appConfigMetadata = appConfigMetadata
		XCTAssertEqual(store.appConfigMetadata, appConfigMetadata)
	}
	
	func testConsentForAutomaticSharingTestResults_initial() throws {
		let store = SecureStore(subDirectory: "test")
		XCTAssertFalse(store.isSubmissionConsentGiven, "isAllowedToAutomaticallyShareTestResults should be 'false' after initialization")

	}
}
