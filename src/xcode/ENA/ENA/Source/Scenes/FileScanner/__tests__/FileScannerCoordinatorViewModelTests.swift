//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FileScannerCoordinatorViewModelTests: CWATestCase {

	// MARK: - UIDocumentPicker

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scanImageFile(UIImage())

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PickImageWithoutQRCode_THEN_Error() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scanImageFile(UIImage())

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedFileWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

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
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PasswordProtectedPDFFileWithoutQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		viewModel.missingPasswordForPDF = { password in
			password("12345")
		}

		// WHEN
		let testBundle = Bundle(for: FileScannerCoordinatorViewModelTests.self)
		let url = try XCTUnwrap(testBundle.url(forResource: "encrypted.pdf", withExtension: nil))

		let documentPicker: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: false)
		} else {
			documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		viewModel.documentPicker(documentPicker, didPickDocumentsAt: [url])

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_PasswordProtectedPDFFileWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		viewModel.missingPasswordForPDF = { password in
			password("123456")
		}

		// WHEN
		let testBundle = Bundle(for: FileScannerCoordinatorViewModelTests.self)
		let url = try XCTUnwrap(testBundle.url(forResource: "pass123456.pdf", withExtension: nil))

		let documentPicker: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: false)
		} else {
			documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		viewModel.documentPicker(documentPicker, didPickDocumentsAt: [url])

		// THEN
		waitForExpectations(timeout: .short)
	}

	// MARK: UIImagePicker

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedImageWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scanImageFile(UIImage())

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedImageWithoutQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "no qr code found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake(),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFailed = { error in
			if case .noQRCodeFound = error {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scanImageFile(UIImage())

		// THEN
		waitForExpectations(timeout: .short)
	}

	// MARK: PHPicker

	@available(iOS 14, *)
	func testGIVEN_FileScannerCoordinatorViewModel_WHEN_SelectedPhotoPickerWithQRCode_THEN_QRCodeResult() throws {
		// GIVEN
		let expectation = expectation(description: "result found")

		let viewModel = FileScannerCoordinatorViewModel(
			qrCodeDetector: QRCodeDetectorFake("something found"),
			qrCodeParser: QRCodeParsableMock(acceptAll: true)
		)

		viewModel.processingFinished = { result in
			if case .certificate = result {
				expectation.fulfill()
			}
		}

		// WHEN
		viewModel.scanImageFile(UIImage())

		// THEN
		waitForExpectations(timeout: .short)
	}

}
