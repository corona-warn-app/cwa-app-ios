//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class StoreTests: XCTestCase {
	private var store: SecureStore!

	override func setUpWithError() throws {
		XCTAssertNoThrow(try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment()))
		store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment())
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

	func testNumberOfSuccesfulSubmissions_Success() {
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, 0)
		store.numberOfSuccesfulSubmissions = Int64.max
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.max)
		store.numberOfSuccesfulSubmissions = Int64.min
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.min)
	}

	func testInitialSubmitCompleted_Success() {
		XCTAssertFalse(store.initialSubmitCompleted)
		store.initialSubmitCompleted = true
		XCTAssertTrue(store.initialSubmitCompleted)
		store.initialSubmitCompleted = false
		XCTAssertFalse(store.initialSubmitCompleted)
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

		let tmpStore: Store = try SecureStore(at: directoryURL, key: "12345678", serverEnvironment: ServerEnvironment())

		// Prepare data
		let testTimeStamp: Int64 = 1466467200  // 21.06.2016
		let testDate1 = Date(timeIntervalSince1970: Double(testTimeStamp))

		XCTAssertTrue(tmpStore.isOnboarded)
		XCTAssertEqual(tmpStore.dateOfAcceptedPrivacyNotice?.description, testDate1.description)
		XCTAssertEqual(tmpStore.teleTan, "97RR2D5644")
		XCTAssertEqual(tmpStore.tan, "97RR2D5644")
		XCTAssertEqual(tmpStore.testGUID, "00000000-0000-4000-8000-000000000000")
		XCTAssertTrue(tmpStore.devicePairingConsentAccept)
		XCTAssertEqual(tmpStore.devicePairingConsentAcceptTimestamp, testTimeStamp)
		XCTAssertEqual(tmpStore.devicePairingSuccessfulTimestamp, testTimeStamp)
		XCTAssertTrue(tmpStore.allowRiskChangesNotification)
		XCTAssertTrue(tmpStore.allowTestsStatusNotification)
		XCTAssertEqual(tmpStore.registrationToken, "")
		XCTAssertTrue(tmpStore.hasSeenSubmissionExposureTutorial)
		XCTAssertEqual(tmpStore.testResultReceivedTimeStamp, testTimeStamp)
		XCTAssertEqual(tmpStore.lastSuccessfulSubmitDiagnosisKeyTimestamp, testTimeStamp)
		XCTAssertEqual(tmpStore.numberOfSuccesfulSubmissions, 1)
		XCTAssertTrue(tmpStore.initialSubmitCompleted)
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
		let store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment())

		let isOnboarded = store.isOnboarded
		store.isOnboarded.toggle()
		XCTAssertNotEqual(isOnboarded, store.isOnboarded)

		let allowRiskChangesNotification = store.allowRiskChangesNotification
		store.allowRiskChangesNotification.toggle()
		XCTAssertNotEqual(allowRiskChangesNotification, store.allowRiskChangesNotification)

		// etc.
	}

	func testBackupRestoration() throws {
		// prerequisite: clean state
		let keychain = try KeychainHelper()
		try keychain.clearInKeychain(key: SecureStore.keychainDatabaseKey)

		// 1. create store and store db key in keychain
		let store = SecureStore(subDirectory: "test", serverEnvironment: ServerEnvironment())
		XCTAssertFalse(store.isOnboarded)
		// user finished onboarding and used the app…
		store.isOnboarded.toggle()
		store.testGUID = UUID().uuidString

		guard let databaseKey = keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey) else {
			XCTFail("expected a key!")
			return
		}

		// 2. restored with db key in keychain
		// This simulates iCloud keychain
		let restore = SecureStore(subDirectory: "test", serverEnvironment: ServerEnvironment())
		XCTAssertTrue(restore.isOnboarded)
		XCTAssertEqual(restore.testGUID, store.testGUID)
		// still the same key?
		XCTAssertEqual(databaseKey, keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey))

		// 3. db key in keychain 'changed' for some reason
		// swiftlint:disable:next force_unwrapping
		try keychain.saveToKeychain(key: SecureStore.keychainDatabaseKey, data: "corrupted".data(using: .utf8)!)
		let restore2 = SecureStore(subDirectory: "test", serverEnvironment: ServerEnvironment())
		// database reset?
		XCTAssertFalse(restore2.isOnboarded)
		XCTAssertEqual(restore2.testGUID, "") // init values…
		XCTAssertNotEqual(databaseKey, keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey))

		// cleanup
		store.clearAll(key: nil)
	}

	func testConfigCaching() throws {
		let store = SecureStore(subDirectory: "test", serverEnvironment: ServerEnvironment())
		store.appConfigMetadata = nil
		XCTAssertNil(store.appConfigMetadata)

		let tag = "fake_\(Int.random(in: 100...999))"
		let config = CachingHTTPClientMock.staticAppConfig
		let appConfigMetadata = AppConfigMetadata(lastAppConfigETag: tag, lastAppConfigFetch: Date(), appConfig: config)
		
		store.appConfigMetadata = appConfigMetadata
		XCTAssertEqual(store.appConfigMetadata, appConfigMetadata)
	}
	
	func testConsentForAutomaticSharingTestResults_initial() throws {
		let store = SecureStore(subDirectory: "test", serverEnvironment: ServerEnvironment())
		XCTAssertFalse(store.isSubmissionConsentGiven, "isAllowedToAutomaticallyShareTestResults should be 'false' after initialization")

	}
}
