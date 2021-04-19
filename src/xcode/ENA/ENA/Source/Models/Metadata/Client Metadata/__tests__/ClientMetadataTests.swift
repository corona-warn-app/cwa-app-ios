////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class ClientMetadataTests: XCTestCase {

	func testGIVEN_ClientMetadat_WHEN_AnalyticsCollectIsCalled_THEN_ClientMetadataAreLoggedCorrect() {
		// GIVEN
		let mockStore = MockTestStore()
		Analytics.setupMock(store: mockStore)
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true

		XCTAssertNil(mockStore.clientMetadata, "Client metadata should be initially nil")
		let appVersionParts = Bundle.main.appVersion.split(separator: ".")
		guard appVersionParts.count == 3,
			  let majorAppVersion = Int(appVersionParts[0]),
			  let minorAppVersion = Int(appVersionParts[1]),
			  let patchAppVersion = Int((appVersionParts[2])) else {
			return
		}
		let expectedAppVersion = Version(major: majorAppVersion, minor: minorAppVersion, patch: patchAppVersion)
		// iOSVersion
		let expectediosVersion = Version(
			major: ProcessInfo().operatingSystemVersion.majorVersion,
			minor: ProcessInfo().operatingSystemVersion.minorVersion,
			patch: ProcessInfo().operatingSystemVersion.patchVersion
		)
		// eTag
		let expectedETag = "fake"
		
		// WHEN
		mockStore.clientMetadata = ClientMetadata(etag: expectedETag)
	
		// THEN
		XCTAssertNotNil(mockStore.clientMetadata, "Client metadata should be not nil")
		XCTAssertEqual(expectedAppVersion, mockStore.clientMetadata?.cwaVersion, "appVersion not equal clientMetaData appVersion")
		XCTAssertEqual(expectediosVersion, mockStore.clientMetadata?.iosVersion, "iosVersion not equal clientMetaData iosVersion")
		XCTAssertEqual(expectedETag, mockStore.clientMetadata?.eTag, "eTag not equal clientMetaData eTag")
	}
}
