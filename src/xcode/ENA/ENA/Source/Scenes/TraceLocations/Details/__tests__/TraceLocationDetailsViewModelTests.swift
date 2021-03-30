////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class TraceLocationDetailsViewModelTests: XCTestCase {

	func testQRCodePosterTemplate() throws {
		let store = MockTestStore()
		let client = CachingHTTPClientMock(store: store)
		let provider = QRCodePosterTemplateProvider(client: client, store: store)

		let viewModel = TraceLocationDetailsViewModel(
			traceLocation: TraceLocation.mock(),
			store: store,
			qrCodePosterTemplateProvider: provider
		)
		
		viewModel.fetchQRCodePosterTemplateData { templateData in
			switch templateData {
			case .success:
				XCTAssertNotNil(viewModel.qrCodePosterTemplate)
				
				// Check for QR Code poster template
				XCTAssertNotNil(viewModel.qrCodePosterTemplate.template)
				
				// Check for QR code offsets
				XCTAssertNotNil(viewModel.qrCodePosterTemplate.offsetX)
				XCTAssertNotNil(viewModel.qrCodePosterTemplate.offsetY)

				// Check for QR Code image size
				XCTAssertNotNil(viewModel.qrCodePosterTemplate.qrCodeSideLength)
				
				// Check for QR Code text details
				XCTAssertNotNil(viewModel.qrCodePosterTemplate.descriptionTextBox)
			case let .failure(error):
				XCTFail(error.localizedDescription)
			}
		}
	}

}
