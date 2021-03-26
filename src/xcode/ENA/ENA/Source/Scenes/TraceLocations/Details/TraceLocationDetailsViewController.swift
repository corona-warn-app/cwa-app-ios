//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

class TraceLocationDetailsViewController: UIViewController, FooterViewHandling {


	// MARK: - Init

	init(
		viewModel: TraceLocationDetailsViewModel,
		onPrintVersionButtonTap: @escaping (PDFView) -> Void,
		onDuplicateButtonTap: @escaping (TraceLocation) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel

		self.onPrintVersionButtonTap = onPrintVersionButtonTap
		self.onDuplicateButtonTap = onDuplicateButtonTap
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .background)

		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)

	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			self.footerView?.setLoadingIndicator(true, disable: true, button: .primary)
			
			generateAndPassQRCodePoster()
		case .secondary:
			onDuplicateButtonTap(viewModel.traceLocation)
		}
	}

	// MARK: - Private

	private let viewModel: TraceLocationDetailsViewModel

	private let onPrintVersionButtonTap: (PDFView) -> Void
	private let onDuplicateButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void
	private var subscriptions = [AnyCancellable]()

	private func generateAndPassQRCodePoster() {
		viewModel.fetchQRCodePosterTemplateData { [weak self] templateData in
			switch templateData {
			case let .success(templateData):
				DispatchQueue.main.async { [weak self] in
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
					do {
						let pdfView = try self?.createPdfView(templateData: templateData)
						self?.onPrintVersionButtonTap(pdfView ?? PDFView())
					} catch {
						Log.error("Could not create the PDF view.", log: .qrCode, error: error)
					}
				}
			case let .failure(error):
				self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
				Log.error("Could not get QR code poster template.", log: .qrCode, error: error)
				return
			}
		}
	}

	private func createPdfView(templateData: SAP_Internal_Pt_QRCodePosterTemplateIOS) throws -> PDFView {
		let pdfView = PDFView()
		let pdfDocument = PDFDocument(data: templateData.template)

		let qrSideLength = CGFloat(templateData.qrCodeSideLength)
		guard let qrCodeImage = viewModel.traceLocation.generateQRCode(size: CGSize(width: qrSideLength, height: qrSideLength)) else { return pdfView }
		let textDetails = templateData.descriptionTextBox
		let textColor = UIColor().hexStringToUIColor(hex: textDetails.fontColor)
		
		try? pdfDocument?.embedImageAndText(
			image: qrCodeImage,
			at: CGPoint(x: CGFloat(templateData.offsetX), y: CGFloat(templateData.offsetY)),
			text: viewModel.traceLocation.address,
			of: CGFloat(textDetails.fontSize),
			and: textColor,
			with: CGRect(x: CGFloat(textDetails.offsetX), y: CGFloat(textDetails.offsetY), width: CGFloat(textDetails.width), height: CGFloat(textDetails.height))
		)

		pdfView.document = pdfDocument
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.autoScales = true
		return pdfView
	}
}
