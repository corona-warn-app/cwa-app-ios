//
// 🦠 Corona-Warn-App
//

@testable import ENA
import FMDB
import XCTest

final class AppUpdateCheckerHelperTests: XCTestCase {

	private var mockStore: MockTestStore!
	private var sut: AppUpdateCheckHelper!
	private let currentVersion = "1.0.0"

	override func setUp() {
		super.setUp()
		mockStore = MockTestStore()
		sut = AppUpdateCheckHelper(appConfigurationProvider: CachedAppConfigurationMock(), store: mockStore)
	}
	
	func testAlertType_none() {
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 1, 0), latestVersion: Version(1, 0, 0)),
			.none
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 0, 0), latestVersion: Version(0, 0, 0)),
			.none
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 99, 99), latestVersion: Version(0, 99, 99)),
			.none
		)
	}

	func testAlertType_update() {
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 1, 0), latestVersion: Version(1, 1, 0)),
			.update
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 0, 0), latestVersion: Version(1, 99, 99)),
			.update
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(0, 1, 99), latestVersion: Version(1, 99, 99)),
			.update
		)
	}

	func testAlertType_forceUpdate() {
		XCTAssertEqual(sut.alertTypeFrom(
			currentVersion: currentVersion, minVersion: Version(1, 1, 0), latestVersion: Version(1, 1, 0)),
			.forceUpdate
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(99, 99, 99), latestVersion: Version(99, 99, 99)),
			.forceUpdate
		)
		XCTAssertEqual(
			sut.alertTypeFrom(currentVersion: currentVersion, minVersion: Version(1, 0, 1), latestVersion: Version(1, 0, 1)),
			.forceUpdate
		)
	}

	func testAlert_none() {
		let alert = sut.createAlert(.none, vc: nil)
		XCTAssertNil(alert)
	}

	func testAlert_update() {
		let alert = sut.createAlert(.update, vc: nil)
		XCTAssertNotNil(alert)
		XCTAssertEqual(alert?.actions.count, 2)
	}

	func testAlert_forceUpdate() {
		let alert = sut.createAlert(.forceUpdate, vc: nil)
		XCTAssertNotNil(alert)
		XCTAssertEqual(alert?.actions.count, 1)
	}
}

private typealias Version = SAP_Internal_V2_SemanticVersion
private extension SAP_Internal_V2_SemanticVersion {
	init(_ major: Int, _ minor: Int, _ patch: Int) {
		self.init()
		self.major = UInt32(major)
		self.minor = UInt32(minor)
		self.patch = UInt32(patch)
	}
}
