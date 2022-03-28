//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RecycleBinTests: XCTestCase {

	func test_moveToBin() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycledItem.certificate(HealthCertificate.mock())

		recycleBin.moveToBin(item)

		XCTAssertEqual(mockStore.recycleBinItems.count, 1)
	}

	func test_canRestore_Test() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)
		let item = RecycleBinItem(
			recycledAt: Date(),
			item: .userCoronaTest(.antigen(.mock()))
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		var handler = UserTestRestorationHandlerFake()
		handler.canRestore = { _ in
			canRestoreExpectation.fulfill()
			return .success(())
		}
		handler.restore = { _ in }

		recycleBin.userTestRestorationHandler = handler
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
			recycledAt: Date(),
			item: .userCoronaTest(.antigen(.mock()))
		)

		let canRestoreExpectation = expectation(description: "canRestore is called.")
		var handler = UserTestRestorationHandlerFake()
		handler.canRestore = { _ in
			canRestoreExpectation.fulfill()
			return .failure(.testTypeAlreadyRegistered)
		}
		handler.restore = { _ in }


		recycleBin.userTestRestorationHandler = handler
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
		var handler = CertificateRestorationHandlerFake()
		handler.restore = { _ in
			canRestoreExpectation.fulfill()
		}

		recycleBin.certificateRestorationHandler = handler

		// First put an item into the bin and check if its persisted.
		let binItem = recycleBin.moveToBin(item)
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
		let binItem = recycleBin.moveToBin(item)
		XCTAssertEqual(mockStore.recycleBinItems.count, 1)

		// Then remove the item and check if its deleted from bin.
		recycleBin.remove(binItem)
		XCTAssertEqual(mockStore.recycleBinItems.count, 0)
	}

	func test_RemoveAll() {
		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)

		// First put some items into the bin and check if its persisted.

		recycleBin.moveToBin(
			RecycledItem.certificate(
				HealthCertificate.mock(base45: HealthCertificateMocks.mockBase45)
			)
		)

		recycleBin.moveToBin(
			RecycledItem.certificate(
				HealthCertificate.mock(base45: HealthCertificateMocks.firstBase45Mock)
			)
		)

		recycleBin.moveToBin(
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

		recycleBin.moveToBin(item)
		XCTAssertNotNil(recycleBin.item(for: certificate.base45))
	}

	func test_Cleanup() throws {
		let now = Date()
		let dateBefore30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -31, to: now))
		let date30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -30, to: now))
		let dateAfter30Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -29, to: now))

		let mockStore = MockTestStore()
		let recycleBin = RecycleBin(store: mockStore)

		recycleBin.moveToBin(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.mockBase45
				)
			),
			recycledAt: dateBefore30Days
		)

		recycleBin.moveToBin(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.firstBase45Mock
				)
			),
			recycledAt: date30Days
		)

		recycleBin.moveToBin(
			RecycledItem.certificate(
				HealthCertificate.mock(
					base45: HealthCertificateMocks.lastBase45Mock
				)
			),
			recycledAt: dateAfter30Days
		)

		XCTAssertEqual(mockStore.recycleBinItems.count, 3)

		recycleBin.cleanup(now)

		XCTAssertEqual(mockStore.recycleBinItems.count, 2)
	}
}
