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
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testNumberOfRowsWithEmptyEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
	}

	func testNumberOfRowsWithNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 3)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForDescriptionSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: RecycleBinViewModel.Section.description.rawValue)))
	}

	func testCanEditRowForEntriesSection() throws {
		let store = MockTestStore()

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: RecycleBinViewModel.Section.entries.rawValue)))
	}

	func testRestoringCertificate() throws {
		let store = MockTestStore()

		let pcrTest: CoronaTest = .pcr(.mock())
		let antigenTest: CoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock(base45: HealthCertificateMocks.mockBase45))),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .coronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .coronaTest(antigenTest))
		]

		let restoreHandlerExpectation = expectation(description: "restore called on handler")
		var certificateRestorationHandler = CertificateRestorationHandlerFake()
		certificateRestorationHandler.restore = { certificate in
			XCTAssertEqual(certificate, .mock(base45: HealthCertificateMocks.mockBase45))
			restoreHandlerExpectation.fulfill()
		}

		let recycleBin = RecycleBin(store: store)
		recycleBin.certificateRestorationHandler = certificateRestorationHandler

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: recycleBin
		)

		viewModel.restoreItem(at: IndexPath(row: 0, section: 1))

		waitForExpectations(timeout: .medium)

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [pcrTest.recycleBinIdentifier, antigenTest.recycleBinIdentifier])
	}

	func testRemoveEntry() throws {
		let store = MockTestStore()

		let pcrTest: CoronaTest = .pcr(.mock())
		let antigenTest: CoronaTest = .antigen(.mock())

		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock(base45: HealthCertificateMocks.mockBase45))),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -15), item: .coronaTest(pcrTest)),
			RecycleBinItem(recycledAt: Date(timeIntervalSinceNow: -35), item: .coronaTest(antigenTest))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		viewModel.removeEntry(at: IndexPath(row: 1, section: 1))

		let remainingIds = store.recycleBinItemsSubject.value.map { $0.item.recycleBinIdentifier }.sorted()
		XCTAssertEqual(remainingIds, [antigenTest.recycleBinIdentifier, HealthCertificateMocks.mockBase45])
	}

	func testRemoveAll() throws {
		let store = MockTestStore()
		store.recycleBinItems = [
			RecycleBinItem(recycledAt: Date(), item: .certificate(.mock())),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.pcr(.mock(uniqueCertificateIdentifier: "a")))),
			RecycleBinItem(recycledAt: Date(), item: .coronaTest(.antigen(.mock(uniqueCertificateIdentifier: "b"))))
		]

		let viewModel = RecycleBinViewModel(
			store: store,
			recycleBin: RecycleBin(store: store)
		)

		viewModel.removeAll()

		XCTAssertTrue(store.recycleBinItemsSubject.value.isEmpty)
	}

}
