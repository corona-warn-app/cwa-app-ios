//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

class TraceLocationDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FooterViewHandling {

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
		setupView()
		setupTableView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		didCalculateGradientHeight = false
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
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard didCalculateGradientHeight == false,
			indexPath == IndexPath(row: 0, section: TraceLocationDetailsViewModel.TableViewSections.qrCode.rawValue) else {
			return
		}

		let cellRect = tableView.rectForRow(at: indexPath)
		let result = view.convert(cellRect, from: tableView)
		backgroundView.gradientHeightConstraint.constant = result.midY
		didCalculateGradientHeight = true
	}

	// MARK: - UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return TraceLocationDetailsViewModel.TableViewSections.allCases.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRowsPerSection
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = TraceLocationDetailsViewModel.TableViewSections(rawValue: indexPath.section) else {
			fatalError("unknown section - can't match a cell type")
		}
		switch section {
		case .header:
			let cell = tableView.dequeueReusableCell(cellType: TraceLocationDetailsHeaderCell.self, for: indexPath)
			cell.configure(viewModel.title)
			return cell
		
		case .location:
			let cell = tableView.dequeueReusableCell(cellType: TraceLocationDetailsLocationCell.self, for: indexPath)
			cell.configure(viewModel.address)
			return cell
		
		case .qrCode:
			let cell = tableView.dequeueReusableCell(cellType: TraceLocationDetailsQRCodeCell.self, for: indexPath)
			cell.configure(viewModel.qrCode)
			return cell
			
		case .dateTime:
			let cell = tableView.dequeueReusableCell(cellType: TraceLocationDetailsDateTimeCell.self, for: indexPath)
			cell.configure(viewModel.date)
			return cell
		}
	}

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
				
				Log.error("Could not retrieve QR code poster template from protobuf.", log: .qrCode, error: error)
				return
			}
		}
	}

	private func createPdfView(templateData: SAP_Internal_Pt_QRCodePosterTemplateIOS) throws -> PDFView {
		let pdfView = PDFView()
		let pdfDocument = PDFDocument(data: templateData.template)

		let qrSideLength = CGFloat(templateData.qrCodeSideLength)
		guard let qrCodeImage = viewModel.traceLocation.qrCode(size: CGSize(width: qrSideLength, height: qrSideLength)) else { return pdfView }
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

	// MARK: - Private
	private let backgroundView = GradientBackgroundView()
	private let tableView = UITableView(frame: .zero, style: .plain)

	private let viewModel: TraceLocationDetailsViewModel

	private let onPrintVersionButtonTap: (PDFView) -> Void
	private let onDuplicateButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void
	private var didCalculateGradientHeight: Bool = false
	private var subscriptions = [AnyCancellable]()
	private var tableContentObserver: NSKeyValueObservation!

	private func setupView() {
		parent?.view.backgroundColor = .clear
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView)

		let gradientNavigationView = GradientNavigationView(
			didTapCloseButton: { [weak self] in
				self?.onDismiss()
			}
		)
		gradientNavigationView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(gradientNavigationView)

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear
		backgroundView.addSubview(tableView)

		NSLayoutConstraint.activate(
			[
				backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
				backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

				gradientNavigationView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24.0),
				gradientNavigationView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16.0),
				gradientNavigationView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16.0),

				tableView.topAnchor.constraint(equalTo: gradientNavigationView.bottomAnchor, constant: 20.0),
				tableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
				tableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
		])

		tableContentObserver = tableView.observe(\UITableView.contentOffset, options: .new) { [weak self] tableView, change in
			guard let self = self,
				  let yOffset = change.newValue?.y else {
				return
			}
			let offsetLimit = tableView.frame.origin.y
			self.backgroundView.updatedTopLayout(with: yOffset, limit: offsetLimit)
		}
	}

	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never

		tableView.register(TraceLocationDetailsHeaderCell.self, forCellReuseIdentifier: TraceLocationDetailsHeaderCell.reuseIdentifier)
		tableView.register(TraceLocationDetailsLocationCell.self, forCellReuseIdentifier: TraceLocationDetailsLocationCell.reuseIdentifier)
		tableView.register(TraceLocationDetailsQRCodeCell.self, forCellReuseIdentifier: TraceLocationDetailsQRCodeCell.reuseIdentifier)
		tableView.register(TraceLocationDetailsDateTimeCell.self, forCellReuseIdentifier: TraceLocationDetailsDateTimeCell.reuseIdentifier)
	}
}
