//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FileScannerCoordinatorTests: XCTestCase {

	func test_When_finishedPickingImage_Then_dismissViewControllerIsCalled() {
		let viewControllerSpy = ViewControllerSpy()
		let viewModel = FileScannerViewModelStub()
		let fileScannerCoordinator = FileScannerCoordinator(
			viewControllerSpy,
			fileScannerViewModel: viewModel,
			qrCodeFound: { _ in },
			noQRCodeFound: { }
		)
		fileScannerCoordinator.start()

		viewModel.finishedPickingImage?()

		XCTAssertTrue(viewControllerSpy.dimissCalled)
	}

	func test_When_processingStarted_Then_activityIndicatorIsShown() {
		let viewControllerSpy = ViewControllerSpy()
		let viewModel = FileScannerViewModelStub()
		let fileScannerCoordinator = FileScannerCoordinator(
			viewControllerSpy,
			fileScannerViewModel: viewModel,
			qrCodeFound: { _ in },
			noQRCodeFound: { }
		)
		fileScannerCoordinator.start()

		viewModel.processingStarted?()

		XCTAssertTrue(viewControllerSpy.viewSpy.addSubViewCalled)
	}

	func test_When_processingFinished_Then_qrCodeFoundIsCalled() {
		let viewControllerSpy = ViewControllerSpy()
		let viewModel = FileScannerViewModelStub()

		let qrCodeFoundExpectation = expectation(description: "qrCodeFound is called.")
		let fileScannerCoordinator = FileScannerCoordinator(
			viewControllerSpy,
			fileScannerViewModel: viewModel,
			qrCodeFound: { _ in
				qrCodeFoundExpectation.fulfill()
			},
			noQRCodeFound: { }
		)
		fileScannerCoordinator.start()

		let mockResult = QRCodeResult.traceLocation(TraceLocation.mock())
		viewModel.processingFinished?(mockResult)

		waitForExpectations(timeout: .short)
	}

	func test_When_processingFailed_Then_AlertIsPresented() {
		let viewControllerSpy = ViewControllerSpy()
		let viewModel = FileScannerViewModelStub()

		let fileScannerCoordinator = FileScannerCoordinator(
			viewControllerSpy,
			fileScannerViewModel: viewModel,
			qrCodeFound: { _ in },
			noQRCodeFound: { }
		)
		fileScannerCoordinator.start()

		viewModel.processingFailed?(.noQRCodeFound)

		XCTAssertTrue(viewControllerSpy.presentCalled)

		guard viewControllerSpy.viewControllerToPresent is UIAlertController else {
			XCTFail("UIAlertController expected to be presented.")
			return
		}
	}

	func test_When_missingPasswordForPDF_Then_AlertIsPresented() {
		let viewControllerSpy = ViewControllerSpy()
		let viewModel = FileScannerViewModelStub()

		let fileScannerCoordinator = FileScannerCoordinator(
			viewControllerSpy,
			fileScannerViewModel: viewModel,
			qrCodeFound: { _ in },
			noQRCodeFound: { }
		)
		fileScannerCoordinator.start()

		viewModel.missingPasswordForPDF?({ _ in })

		XCTAssertTrue(viewControllerSpy.presentCalled)

		guard viewControllerSpy.viewControllerToPresent is UIAlertController else {
			XCTFail("UIAlertController expected to be presented.")
			return
		}
	}
}

private class ViewSpy: UIView {
	var addSubViewCalled: Bool = false

	override func addSubview(_ view: UIView) {
		super.addSubview(view)

		addSubViewCalled = true
	}
}

private class ViewControllerSpy: UIViewController {
	var dimissCalled: Bool = false
	var presentCalled: Bool = false
	var viewControllerToPresent: UIViewController?
	let viewSpy = ViewSpy()

	override func loadView() {
		self.view = viewSpy
	}

	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		super.dismiss(animated: flag, completion: completion)
		dimissCalled = true
	}

	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		super.present(viewControllerToPresent, animated: flag, completion: completion)
		presentCalled = true
		self.viewControllerToPresent = viewControllerToPresent
	}
}

private class FileScannerViewModelStub: FileScannerProcessing {
	var finishedPickingImage: (() -> Void)?
	var processingStarted: (() -> Void)?
	var processingFinished: ((QRCodeResult) -> Void)?
	var processingFailed: ((FileScannerError) -> Void)?
	var missingPasswordForPDF: ((@escaping (String) -> Void) -> Void)?
}
