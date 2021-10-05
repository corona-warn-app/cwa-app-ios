//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FileScannerCoordinatorViewModelTests: CWATestCase {

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeParser: MockQRCodeParsable(acceptAll: true),
			finishedPickingImage: {},
			processingStarted: {},
			processingFinished: { result in
				if case .certificate(_, _) = result {
					expectation.fulfill()
				}
			},
			processingFailed: { _ in },
			missingPasswordForPDF: { _ in }
		)

		// WHEN
		let testBundle = Bundle(for: FileScannerCoordinatorViewModelTests.self)
		let url = try XCTUnwrap(testBundle.url(forResource: "certificate.jpg", withExtension: nil))

		let documentPicker: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: false)
		} else {
			documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		viewModel.documentPicker(documentPicker, didPickDocumentsAt: [url])

		// THEN
		waitForExpectations(timeout: .qrcode)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithoutQRCode_THEN_Error() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeParser: MockQRCodeParsable(acceptAll: true),
			finishedPickingImage: {},
			processingStarted: {},
			processingFinished: { _ in },
			processingFailed: { error in
				if case .noQRCodeFound = error {
					expectation.fulfill()
				}
			},
			missingPasswordForPDF: { _ in }
		)

		// WHEN
		let testBundle = Bundle(for: FileScannerCoordinatorViewModelTests.self)
		let url = try XCTUnwrap(testBundle.url(forResource: "landscape.png", withExtension: nil))

		let documentPicker: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: false)
		} else {
			documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		viewModel.documentPicker(documentPicker, didPickDocumentsAt: [url])

		// THEN
		waitForExpectations(timeout: .long)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedFileWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeParser: MockQRCodeParsable(acceptAll: true),
			finishedPickingImage: {},
			processingStarted: {},
			processingFinished: { result in
				if case .certificate(_, _) = result {
					expectation.fulfill()
				}
			},
			processingFailed: { _ in },
			missingPasswordForPDF: { _ in }
		)

		// WHEN
		let testBundle = Bundle(for: FileScannerCoordinatorViewModelTests.self)
		let url = try XCTUnwrap(testBundle.url(forResource: "simpleCertificate.pdf", withExtension: nil))

		let documentPicker: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: false)
		} else {
			documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		viewModel.documentPicker(documentPicker, didPickDocumentsAt: [url])

		// THEN
		waitForExpectations(timeout: .qrcode)
	}

}
