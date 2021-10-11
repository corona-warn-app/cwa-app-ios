//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RecycleBinTests: XCTestCase {

	func test_Recycle() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycledItem.certificate(HealthCertificate.mock())

		recycleBin.recycle(item)

		XCTAssertEqual(mockStore.recycleBinItems.count, 1)
	}

	func test_canRestore_Certificate() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycleBinItem(
			recycleDate: Date(),
			item: RecycledItem.certificate(HealthCertificate.mock())
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		let handler = CertificateRestorationHandler(
			canRestore: { _ in
				canRestoreExpectation.fulfill()
				return .success(())
			},
			restore: { _ in }
		)

		recycleBin.certificateRestorationHandler = handler
		let canRestoreResult = recycleBin.canRestore(item)

		guard case .success = canRestoreResult else {
			XCTFail("Success expected")
			return
		}

		waitForExpectations(timeout: .short)
	}

	func test_canRestore_Certificate_Fail() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycleBinItem(
			recycleDate: Date(),
			item: RecycledItem.certificate(HealthCertificate.mock())
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		let handler = CertificateRestorationHandler(
			canRestore: { _ in
				canRestoreExpectation.fulfill()
				return .failure(.some)
			},
			restore: { _ in }
		)

		recycleBin.certificateRestorationHandler = handler
		let canRestoreResult = recycleBin.canRestore(item)

		guard case .failure = canRestoreResult else {
			XCTFail("Failure expected")
			return
		}

		waitForExpectations(timeout: .short)
	}

	func test_canRestore_Test() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycleBinItem(
			recycleDate: Date(),
			item: RecycledItem.coronaTest(CoronaTest.antigen(.mock()))
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		let handler = TestRestorationHandler(
			canRestore: { _ in
				canRestoreExpectation.fulfill()
				return .success(())
			},
			restore: { _ in }
		)

		recycleBin.testRestorationHandler = handler
		let canRestoreResult = recycleBin.canRestore(item)

		guard case .success = canRestoreResult else {
			XCTFail("Success expected")
			return
		}

		waitForExpectations(timeout: .short)
	}

	func test_canRestore_Test_Fail() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycleBinItem(
			recycleDate: Date(),
			item: RecycledItem.coronaTest(CoronaTest.antigen(.mock()))
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		let handler = TestRestorationHandler(
			canRestore: { _ in
				canRestoreExpectation.fulfill()
				return .failure(.some)
			},
			restore: { _ in }
		)

		recycleBin.testRestorationHandler = handler
		let canRestoreResult = recycleBin.canRestore(item)

		guard case .failure = canRestoreResult else {
			XCTFail("Failure expected")
			return
		}

		waitForExpectations(timeout: .short)
	}

	func test_Restore() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycledItem.certificate(HealthCertificate.mock())

		let canRestoreExpectation = expectation(description: "restore is called.")
		let handler = CertificateRestorationHandler(
			canRestore: { _ in
				return .success(())
			},
			restore: { _ in
				canRestoreExpectation.fulfill()
			}
		)

		recycleBin.certificateRestorationHandler = handler

		// First put an item into the bin and check if its persisted.
		let binItem = recycleBin.recycle(item)
		XCTAssertEqual(mockStore.recycleBinItems.count, 1)

		// Then restore the item and check if its deleted from bin.
		recycleBin.restore(binItem)
		XCTAssertEqual(mockStore.recycleBinItems.count, 0)

		waitForExpectations(timeout: .short)
	}

	func test_Remove() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycledItem.certificate(HealthCertificate.mock())

		// First put an item into the bin and check if its persisted.
		let binItem = recycleBin.recycle(item)
		XCTAssertEqual(mockStore.recycleBinItems.count, 1)

		// Then remove the item and check if its deleted from bin.
		recycleBin.remove(binItem)
		XCTAssertEqual(mockStore.recycleBinItems.count, 0)
	}

	func test_RemoveAll() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)

		// First put some items into the bin and check if its persisted.

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(base45: HealthCertificateMocks.mockBase45)
			)
		)

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(base45: HealthCertificateMocks.firstBase45Mock)
			)
		)

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(base45: HealthCertificateMocks.lastBase45Mock)
			)
		)

		XCTAssertEqual(mockStore.recycleBinItems.count, 3)

		// Then remove all and check if its deleted from bin.

		recycleBin.removeAll()
		XCTAssertEqual(mockStore.recycleBinItems.count, 0)
	}

	func test_itemFor() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let certificate = HealthCertificate.mock()
		let item = RecycledItem.certificate(certificate)

		recycleBin.recycle(item)
		XCTAssertNotNil(recycleBin.item(for: certificate.base45))
	}

	func test_Cleanup() throws {
		let now = Date()
		let dateBefore30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -31, to: now))
		let date30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -30, to: now))
		let dateAfter30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -29, to: now))

		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.mockBase45
				)
			),
			recycleDate: dateBefore30Days
		)

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.firstBase45Mock
				)
			),
			recycleDate: date30Days
		)

		recycleBin.recycle(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.lastBase45Mock
				)
			),
			recycleDate: dateAfter30Days
		)

		XCTAssertEqual(mockStore.recycleBinItems.count, 3)

		recycleBin.cleanup(now)

		XCTAssertEqual(mockStore.recycleBinItems.count, 2)
	}
}

struct CertificateRestorationHandler: CertificateRestorationHandling {
	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>)
	var restore: ((HealthCertificate) -> Void)
}

struct TestRestorationHandler: TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>)
	var restore: ((CoronaTest) -> Void)
}
