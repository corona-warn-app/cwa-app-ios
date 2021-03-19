//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

class TraceLocationDetailsViewController: UIViewController, ENANavigationControllerWithFooterChild {

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

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)
		
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		navigationFooterItem.isPrimaryButtonEnabled = false
		navigationFooterItem.isPrimaryButtonLoading = true
		
		generateAndPassQRCodePoster()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		onDuplicateButtonTap(viewModel.traceLocation)
	}
	
	private func generateAndPassQRCodePoster() {
		viewModel.fetchQRCodePosterTemplateData { [weak self] templateData in
			switch templateData {
			case let .success(templateData):
				DispatchQueue.main.async { [weak self] in
					self?.navigationFooterItem.isPrimaryButtonEnabled = true
					self?.navigationFooterItem.isPrimaryButtonLoading = false
					
					guard let pdfView = self?.createPdfView(templateData: templateData) else { return }
					self?.onPrintVersionButtonTap(pdfView)
				}
			case let .failure(error):
				self?.navigationFooterItem.isPrimaryButtonEnabled = true
				self?.navigationFooterItem.isPrimaryButtonLoading = false
				
				Log.error("Could not retrieve QR code poster template from protobuf.", log: .qrCode, error: error)
				return
			}
		}
	}

	private func createPdfView(templateData: SAP_Internal_Pt_QRCodePosterTemplateIOS) -> PDFView {
		let pdfView = PDFView()
		let pdfDocument = PDFDocument(data: templateData.template)

		let placeHolderString = "HTTPS://CORONAWARN.APP/E1/BIPEY33SMVWSA2LQON2W2IDEN5WG64RAONUXIIDBNVSXILBAMNXRBCM4UQARRKM6UQASAHRKCC7CTDWGQ4JCO7RVZSWVIMQK4UPA.GBCAEIA7TEORBTUA25QHBOCWT26BCA5PORBS2E4FFWMJ3UU3P6SXOL7SHUBCA7UEZBDDQ2R6VRJH7WBJKVF7GZYJA6YMRN27IPEP7NKGGJSWX3XQ"
		guard let qrCodeImage = viewModel.traceLocation.generateQRCode(with: placeHolderString, size: CGSize(width: 400, height: 400)) else { return pdfView }

		let textDetails = templateData.description_p
		try? pdfDocument?.embed(
			image: qrCodeImage,
			at: CGPoint(x: CGFloat(templateData.offsetX), y: CGFloat(templateData.offsetY)),
			text: viewModel.traceLocation.address,
			of: CGFloat(textDetails.fontSize),
			hex: textDetails.fontColor,
			with: CGRect(x: CGFloat(textDetails.offsetX), y: CGFloat(textDetails.offsetY), width: CGFloat(textDetails.width), height: CGFloat(textDetails.height))
		)

		pdfView.document = pdfDocument
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.autoScales = true
		return pdfView
	}

	// MARK: - Private

	private let viewModel: TraceLocationDetailsViewModel

	private let onPrintVersionButtonTap: (PDFView) -> Void
	private let onDuplicateButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void

	private var subscriptions = [AnyCancellable]()

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.TraceLocations.Details.printVersionButtonTitle
		item.isPrimaryButtonEnabled = true

		item.secondaryButtonTitle = AppStrings.TraceLocations.Details.duplicateButtonTitle
		item.isSecondaryButtonEnabled = true
		item.isSecondaryButtonHidden = false

		return item
	}()

}
