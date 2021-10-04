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

}
