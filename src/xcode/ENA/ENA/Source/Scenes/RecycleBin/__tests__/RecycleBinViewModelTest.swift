//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class RecycleBinViewModelTest: CWATestCase {

	func testNumberOfSections() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testNumberOfRowsWithEmptyEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
	}

	func testNumberOfRowsWithNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 3)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForDescriptionSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: RecycleBinViewModel.Section.description.rawValue)))
	}

	func testCanEditRowForEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: RecycleBinViewModel.Section.entries.rawValue)))
	}

	func testRestoringCertificate() throws {
		let store = MockTestStore()

		let pcrTest: UserCoronaTest = .pcr(.mock())
		let antigenTest: UserCoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock(base45: HealthCertificateMocks.mockBase45))),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .userCoronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .userCoronaTest(antigenTest))
		]

		let restoreHandlerExpectation = expectation(description: "restore called on handler")
		var certificateRestorationHandler = CertificateRestorationHandlerFake()
		certificateRestorationHandler.restore = { certificate in
			XCTAssertEqual(certificate.base45, HealthCertificateMocks.mockBase45)
			restoreHandlerExpectation.fulfill()
		}

		let recycleBin = RecycleBin(store: store)
		recycleBin.certificateRestorationHandler = certificateRestorationHandler

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: recycleBin,
			onOverwrite: { _ in }
		)

		viewModel.restoreItem(at: IndexPath(row: 0, section: 1))

		waitForExpectations(timeout: .medium)

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [pcrTest.recycleBinIdentifier, antigenTest.recycleBinIdentifier].sorted())
	}

	func testRestoringTestWithoutOverwrite() throws {
		let store = MockTestStore()

		let certificate: HealthCertificate = .mock(base45: HealthCertificateMocks.mockBase45)
		let pcrTest: UserCoronaTest = .pcr(.mock())
		let antigenTest: UserCoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(certificate)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .userCoronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .userCoronaTest(antigenTest))
		]


		let canRestoreHandlerExpectation = expectation(description: "canRestore called on handler")
		let restoreHandlerExpectation = expectation(description: "restore called on handler")
		var testRestorationHandler = UserTestRestorationHandlerFake()

		testRestorationHandler.canRestore = { test in
			XCTAssertEqual(test, pcrTest)
			canRestoreHandlerExpectation.fulfill()

			return .success(())
		}

		testRestorationHandler.restore = { test in
			XCTAssertEqual(test, pcrTest)
			restoreHandlerExpectation.fulfill()
		}

		let recycleBin = RecycleBin(store: store)
		recycleBin.userTestRestorationHandler = testRestorationHandler

		let onOverrideExpectation = expectation(description: "onOverride not called")
		onOverrideExpectation.isInverted = true

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: recycleBin,
			onOverwrite: { _ in
				onOverrideExpectation.fulfill()
			}
		)

		viewModel.restoreItem(at: IndexPath(row: 1, section: 1))

		waitForExpectations(timeout: .medium)

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [antigenTest.recycleBinIdentifier, certificate.recycleBinIdentifier].sorted())
	}

	func testRestoringTestWithOverwrite() throws {
		let store = MockTestStore()

		let certificate: HealthCertificate = .mock(base45: HealthCertificateMocks.mockBase45)
		let pcrTest: UserCoronaTest = .pcr(.mock())
		let antigenTest: UserCoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(certificate)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .userCoronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .userCoronaTest(antigenTest))
		]

		let canRestoreHandlerExpectation = expectation(description: "canRestore called on handler")
		let restoreHandlerExpectation = expectation(description: "restore called on handler")
		var testRestorationHandler = UserTestRestorationHandlerFake()

		testRestorationHandler.canRestore = { test in
			XCTAssertEqual(test, antigenTest)
			canRestoreHandlerExpectation.fulfill()

			return .failure(.testTypeAlreadyRegistered)
		}

		testRestorationHandler.restore = { test in
			XCTAssertEqual(test, antigenTest)
			restoreHandlerExpectation.fulfill()
		}

		let recycleBin = RecycleBin(store: store)
		recycleBin.userTestRestorationHandler = testRestorationHandler

		let onOverrideExpectation = expectation(description: "onOverride called")

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: recycleBin,
			onOverwrite: { recycleBinItem in
				if case let .userCoronaTest(coronaTest) = recycleBinItem.item, coronaTest == antigenTest {} else {
					XCTFail("Expected antigenTest to be passed as parameter")
				}

				onOverrideExpectation.fulfill()
				recycleBin.restore(recycleBinItem)
			}
		)

		viewModel.restoreItem(at: IndexPath(row: 2, section: 1))

		waitForExpectations(timeout: .medium)

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [pcrTest.recycleBinIdentifier, certificate.recycleBinIdentifier].sorted())
	}

	func testRemoveEntry() throws {
		let store = MockTestStore()

		let pcrTest: UserCoronaTest = .pcr(.mock())
		let antigenTest: UserCoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock(base45: HealthCertificateMocks.mockBase45))),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .userCoronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .userCoronaTest(antigenTest))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		viewModel.removeEntry(at: IndexPath(row: 1, section: 1))

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [antigenTest.recycleBinIdentifier, HealthCertificateMocks.mockBase45].sorted())
	}

	func testRemoveAll() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .userCoronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store),
			onOverwrite: { _ in }
		)

		viewModel.removeAll()

		XCTAssertTrue(store.recycleBinItemsSubject.value.isEmpty)
	}

}
