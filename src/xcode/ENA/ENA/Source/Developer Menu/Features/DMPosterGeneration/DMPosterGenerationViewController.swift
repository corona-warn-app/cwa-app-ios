////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit
import PDFKit

// swiftlint:disable:next type_body_length
class DMPosterGenerationViewController: UIViewController, UITextFieldDelegate {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		store: Store
	) {
		self.viewModel = DMPosterGenerationViewModel(traceLocation: traceLocation, qrCodePosterTemplateProvider: qrCodePosterTemplateProvider, store: store)
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = ColorCompatibility.systemBackground
		
		setupView()
		setupNavigationBar()
		self.hideKeyboardWhenTappedAround()
	}

	// MARK: - Protocol UITextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		// in order to prevent movement for top text fields
		if textField.tag != 1 {
			self.animateViewMoving(up: true, moveValue: 200)
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// in order to prevent movement for top text fields
		if textField.tag != 1 {
			self.animateViewMoving(up: false, moveValue: 200)
		}
	}

	func animateViewMoving (up: Bool, moveValue: CGFloat) {
		let movementDuration: TimeInterval = 0.3
		let movement: CGFloat = (up ? -moveValue : moveValue)
		UIView.beginAnimations( "animateView", context: nil)
		UIView.setAnimationBeginsFromCurrentState(true)
		UIView.setAnimationDuration(movementDuration)
		self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
		UIView.commitAnimations()
	}
	
	// MARK: - Private

	private let viewModel: DMPosterGenerationViewModel
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding

	private var qrCodeOffsetXField: UITextField!
	private var qrCodeOffsetYField: UITextField!
	private var qrCodeSideLengthField: UITextField!
	
	private var descriptionOffsetXField: UITextField!
	private var descriptionOffsetYField: UITextField!
	private var descriptionWidthField: UITextField!
	private var descriptionHeightField: UITextField!
	private var descriptionFontSizeField: UITextField!
	private var descriptionFontColorField: UITextField!
	
	private var addressOffsetXField: UITextField!
	private var addressOffsetYField: UITextField!
	private var addressWidthField: UITextField!
	private var addressHeightField: UITextField!
	private var addressFontSizeField: UITextField!
	private var addressFontColorField: UITextField!

	private func setupNavigationBar() {
		title = "Poster Generation"
	}
	
	// swiftlint:disable:next function_body_length
	private func setupView() {
		// setting up labels and text fields
		let titleLabel = UILabel(frame: .zero)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		titleLabel.text = "Enter the parameters to create the poster"
		titleLabel.font = UIFont.enaFont(for: .headline)
		
		let qrCodeOffsetXLabel = UILabel(frame: .zero)
		qrCodeOffsetXLabel.translatesAutoresizingMaskIntoConstraints = false
		qrCodeOffsetXLabel.numberOfLines = 0
		qrCodeOffsetXLabel.text = "QR Code offset x-axis"
		qrCodeOffsetXLabel.font = UIFont.enaFont(for: .subheadline)
	
		qrCodeOffsetXField = UITextField(frame: .zero)
		qrCodeOffsetXField.translatesAutoresizingMaskIntoConstraints = false
		qrCodeOffsetXField.delegate = self
		qrCodeOffsetXField.borderStyle = .bezel
		qrCodeOffsetXField.tag = 1
		
		let qrCodeOffsetYLabel = UILabel(frame: .zero)
		qrCodeOffsetYLabel.translatesAutoresizingMaskIntoConstraints = false
		qrCodeOffsetYLabel.numberOfLines = 0
		qrCodeOffsetYLabel.text = "QR Code offset y-axis"
		qrCodeOffsetYLabel.font = UIFont.enaFont(for: .subheadline)
	
		qrCodeOffsetYField = UITextField(frame: .zero)
		qrCodeOffsetYField.translatesAutoresizingMaskIntoConstraints = false
		qrCodeOffsetYField.delegate = self
		qrCodeOffsetYField.borderStyle = .bezel
		qrCodeOffsetYField.tag = 1
		
		let qrCodeSideLength = UILabel(frame: .zero)
		qrCodeSideLength.translatesAutoresizingMaskIntoConstraints = false
		qrCodeSideLength.numberOfLines = 0
		qrCodeSideLength.text = "QR Code side length"
		qrCodeSideLength.font = UIFont.enaFont(for: .subheadline)
	
		qrCodeSideLengthField = UITextField(frame: .zero)
		qrCodeSideLengthField.translatesAutoresizingMaskIntoConstraints = false
		qrCodeSideLengthField.delegate = self
		qrCodeSideLengthField.borderStyle = .bezel
		qrCodeSideLengthField.tag = 1
		
		let descriptionOffsetXLabel = UILabel(frame: .zero)
		descriptionOffsetXLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionOffsetXLabel.numberOfLines = 0
		descriptionOffsetXLabel.text = "Description offset x-axis"
		descriptionOffsetXLabel.font = UIFont.enaFont(for: .subheadline)
	
		descriptionOffsetXField = UITextField(frame: .zero)
		descriptionOffsetXField.translatesAutoresizingMaskIntoConstraints = false
		descriptionOffsetXField.delegate = self
		descriptionOffsetXField.borderStyle = .bezel
		descriptionOffsetXField.tag = 1

		let descriptionOffsetYLabel = UILabel(frame: .zero)
		descriptionOffsetYLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionOffsetYLabel.numberOfLines = 0
		descriptionOffsetYLabel.text = "Description offset y-axis"
		descriptionOffsetYLabel.font = UIFont.enaFont(for: .subheadline)
	
		descriptionOffsetYField = UITextField(frame: .zero)
		descriptionOffsetYField.translatesAutoresizingMaskIntoConstraints = false
		descriptionOffsetYField.delegate = self
		descriptionOffsetYField.borderStyle = .bezel
		
		let descriptionWidthLabel = UILabel(frame: .zero)
		descriptionWidthLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionWidthLabel.numberOfLines = 0
		descriptionWidthLabel.text = "Description Width"
		descriptionWidthLabel.font = UIFont.enaFont(for: .subheadline)
		
		descriptionWidthField = UITextField(frame: .zero)
		descriptionWidthField.translatesAutoresizingMaskIntoConstraints = false
		descriptionWidthField.delegate = self
		descriptionWidthField.borderStyle = .bezel
		
		let descriptionHeightLabel = UILabel(frame: .zero)
		descriptionHeightLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionHeightLabel.numberOfLines = 0
		descriptionHeightLabel.text = "Description Height"
		descriptionHeightLabel.font = UIFont.enaFont(for: .subheadline)
	
		descriptionHeightField = UITextField(frame: .zero)
		descriptionHeightField.translatesAutoresizingMaskIntoConstraints = false
		descriptionHeightField.delegate = self
		descriptionHeightField.borderStyle = .bezel
		
		let descriptionFontSizeLabel = UILabel(frame: .zero)
		descriptionFontSizeLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionFontSizeLabel.numberOfLines = 0
		descriptionFontSizeLabel.text = "Description Font Size"
		descriptionFontSizeLabel.font = UIFont.enaFont(for: .subheadline)
	
		descriptionFontSizeField = UITextField(frame: .zero)
		descriptionFontSizeField.translatesAutoresizingMaskIntoConstraints = false
		descriptionFontSizeField.delegate = self
		descriptionFontSizeField.borderStyle = .bezel
		
		let descriptionFontColorLabel = UILabel(frame: .zero)
		descriptionFontColorLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionFontColorLabel.numberOfLines = 0
		descriptionFontColorLabel.text = "Description Font Color"
		descriptionFontColorLabel.font = UIFont.enaFont(for: .subheadline)
	
		descriptionFontColorField = UITextField(frame: .zero)
		descriptionFontColorField.translatesAutoresizingMaskIntoConstraints = false
		descriptionFontColorField.delegate = self
		descriptionFontColorField.borderStyle = .bezel
		
		let addressOffsetXLabel = UILabel(frame: .zero)
		addressOffsetXLabel.translatesAutoresizingMaskIntoConstraints = false
		addressOffsetXLabel.numberOfLines = 0
		addressOffsetXLabel.text = "Address offset x-axis"
		addressOffsetXLabel.font = UIFont.enaFont(for: .subheadline)
	
		addressOffsetXField = UITextField(frame: .zero)
		addressOffsetXField.translatesAutoresizingMaskIntoConstraints = false
		addressOffsetXField.delegate = self
		addressOffsetXField.borderStyle = .bezel

		let addressOffsetYLabel = UILabel(frame: .zero)
		addressOffsetYLabel.translatesAutoresizingMaskIntoConstraints = false
		addressOffsetYLabel.numberOfLines = 0
		addressOffsetYLabel.text = "Address offset y-axis"
		addressOffsetYLabel.font = UIFont.enaFont(for: .subheadline)
	
		addressOffsetYField = UITextField(frame: .zero)
		addressOffsetYField.translatesAutoresizingMaskIntoConstraints = false
		addressOffsetYField.delegate = self
		addressOffsetYField.borderStyle = .bezel
		
		let addressWidthLabel = UILabel(frame: .zero)
		addressWidthLabel.translatesAutoresizingMaskIntoConstraints = false
		addressWidthLabel.numberOfLines = 0
		addressWidthLabel.text = "Address Width"
		addressWidthLabel.font = UIFont.enaFont(for: .subheadline)
		
		addressWidthField = UITextField(frame: .zero)
		addressWidthField.translatesAutoresizingMaskIntoConstraints = false
		addressWidthField.delegate = self
		addressWidthField.borderStyle = .bezel
		
		let addressHeightLabel = UILabel(frame: .zero)
		addressHeightLabel.translatesAutoresizingMaskIntoConstraints = false
		addressHeightLabel.numberOfLines = 0
		addressHeightLabel.text = "Address Height"
		addressHeightLabel.font = UIFont.enaFont(for: .subheadline)
	
		addressHeightField = UITextField(frame: .zero)
		addressHeightField.translatesAutoresizingMaskIntoConstraints = false
		addressHeightField.delegate = self
		addressHeightField.borderStyle = .bezel
		
		let addressFontSizeLabel = UILabel(frame: .zero)
		addressFontSizeLabel.translatesAutoresizingMaskIntoConstraints = false
		addressFontSizeLabel.numberOfLines = 0
		addressFontSizeLabel.text = "Address Font Size"
		addressFontSizeLabel.font = UIFont.enaFont(for: .subheadline)
	
		addressFontSizeField = UITextField(frame: .zero)
		addressFontSizeField.translatesAutoresizingMaskIntoConstraints = false
		addressFontSizeField.delegate = self
		addressFontSizeField.borderStyle = .bezel
		
		let addressFontColorLabel = UILabel(frame: .zero)
		addressFontColorLabel.translatesAutoresizingMaskIntoConstraints = false
		addressFontColorLabel.numberOfLines = 0
		addressFontColorLabel.text = "Address Font Color"
		addressFontColorLabel.font = UIFont.enaFont(for: .subheadline)
	
		addressFontColorField = UITextField(frame: .zero)
		addressFontColorField.translatesAutoresizingMaskIntoConstraints = false
		addressFontColorField.delegate = self
		addressFontColorField.borderStyle = .bezel
	
		let generatePosterButton = UIButton(frame: .zero)
		generatePosterButton.translatesAutoresizingMaskIntoConstraints = false
		generatePosterButton.setTitle("Generate Poster", for: .normal)
		generatePosterButton.addTarget(self, action: #selector(generatePosterButtonTapped), for: .touchUpInside)
		generatePosterButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)
		
		// adding three stackviews on to a uiview and then add that view to the scroll view
		let stackViewQRCode = UIStackView(arrangedSubviews: [titleLabel, qrCodeOffsetXLabel, qrCodeOffsetXField, qrCodeOffsetYLabel, qrCodeOffsetYField, qrCodeSideLength, qrCodeSideLengthField])
		stackViewQRCode.translatesAutoresizingMaskIntoConstraints = false
		stackViewQRCode.axis = .vertical
		stackViewQRCode.spacing = 10
		
		let stackViewDescription = UIStackView(arrangedSubviews: [descriptionOffsetXLabel, descriptionOffsetXField, descriptionOffsetYLabel, descriptionOffsetYField] +
									[descriptionWidthLabel, descriptionWidthField, descriptionHeightLabel, descriptionHeightField] +
									[descriptionFontSizeLabel, descriptionFontSizeField, descriptionFontColorLabel, descriptionFontColorField])
		stackViewDescription.translatesAutoresizingMaskIntoConstraints = false
		stackViewDescription.axis = .vertical
		stackViewDescription.spacing = 10
		
		let stackViewAddress = UIStackView(arrangedSubviews: [addressOffsetXLabel, addressOffsetXField, addressOffsetYLabel, addressOffsetYField] +
									[addressWidthLabel, addressWidthField, addressHeightLabel, addressHeightField] +
									[addressFontSizeLabel, addressFontSizeField, addressFontColorLabel, addressFontColorField, generatePosterButton])
		stackViewAddress.translatesAutoresizingMaskIntoConstraints = false
		stackViewAddress.axis = .vertical
		stackViewAddress.spacing = 10
		
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stackViewQRCode)
		contentView.addSubview(stackViewDescription)
		contentView.addSubview(stackViewAddress)
		
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70.0, right: 0)

		view.addSubview(scrollView)
		
		// setting the constraints
		NSLayoutConstraint.activate([
			stackViewQRCode.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			stackViewQRCode.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			stackViewQRCode.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
			
			stackViewDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			stackViewDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			stackViewDescription.topAnchor.constraint(equalTo: stackViewQRCode.bottomAnchor, constant: 10),
			
			stackViewAddress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			stackViewAddress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			stackViewAddress.topAnchor.constraint(equalTo: stackViewDescription.bottomAnchor, constant: 10),
			stackViewAddress.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),

			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
		])
		
		// setting the keyboard type
		qrCodeOffsetXField.keyboardType = .numberPad
		qrCodeOffsetYField.keyboardType = .numberPad
		qrCodeSideLengthField.keyboardType = .numberPad
		descriptionOffsetXField.keyboardType = .numberPad
		descriptionOffsetYField.keyboardType = .numberPad
		descriptionWidthField.keyboardType = .numberPad
		descriptionHeightField.keyboardType = .numberPad
		descriptionFontSizeField.keyboardType = .numberPad
		addressOffsetXField.keyboardType = .numberPad
		addressOffsetYField.keyboardType = .numberPad
		addressWidthField.keyboardType = .numberPad
		addressHeightField.keyboardType = .numberPad
		addressFontSizeField.keyboardType = .numberPad
		
		// setting the default values for the text fields:
		qrCodeOffsetXField.text = "97"
		qrCodeOffsetYField.text = "82"
		qrCodeSideLengthField.text = "400"
		descriptionOffsetXField.text = "80"
		descriptionOffsetYField.text = "510"
		descriptionWidthField.text = "420"
		descriptionHeightField.text = "15"
		descriptionFontSizeField.text = "10"
		descriptionFontColorField.text = "#000000"
		addressOffsetXField.text = "80"
		addressOffsetYField.text = "525"
		addressWidthField.text = "420"
		addressHeightField.text = "15"
		addressFontSizeField.text = "10"
		addressFontColorField.text = "#000000"
	}

	@objc
	private func generatePosterButtonTapped() {
		viewModel.fetchQRCodePosterTemplateData { [weak self] templateData in
			DispatchQueue.main.async { [weak self] in
				switch templateData {
				case let .success(templateData):
					guard let self = self else { return }
						do {
							let pdfView = try self.createPdfView(templateData: templateData)
							let viewController = TraceLocationPrintVersionViewController(
								viewModel: TraceLocationPrintVersionViewModel(pdfView: pdfView, traceLocation: self.viewModel.traceLocation)
							)
							self.navigationController?.pushViewController(viewController, animated: true)
						} catch {
							Log.error("Could not create the PDF view.", log: .qrCode, error: error)
						}
				case let .failure(error):
					Log.error("Could not get QR code poster template.", log: .qrCode, error: error)
					return
				}
			}
		}
	}
	
	private func createPdfView(templateData: SAP_Internal_Pt_QRCodePosterTemplateIOS) throws -> PDFView {
		let pdfView = PDFView()
		let pdfDocument = PDFDocument(data: templateData.template)
		
		guard let qrCodeImage = viewModel.traceLocation.qrCode(size: CGSize(width: qrCodeSideLengthField.cgFloatValue, height: qrCodeSideLengthField.cgFloatValue), qrCodeErrorCorrectionLevel: .medium) else { return pdfView }
		guard let hexDescriptionColorString = descriptionFontColorField.text else { return pdfView }
		guard let hexAddressColorString = addressFontColorField.text else { return pdfView }
		
		let descriptionText = PDFText(
			text: viewModel.title,
			size: descriptionFontSizeField.cgFloatValue,
			color: UIColor().hexStringToUIColor(hex: hexDescriptionColorString),
			rect: CGRect(
				x: descriptionOffsetXField.cgFloatValue,
				y: descriptionOffsetYField.cgFloatValue,
				width: descriptionWidthField.cgFloatValue,
				height: descriptionHeightField.cgFloatValue
			)
		)
		
		let addressText = PDFText(
			text: viewModel.address,
			size: addressFontSizeField.cgFloatValue,
			color: UIColor().hexStringToUIColor(hex: hexAddressColorString),
			rect: CGRect(
				x: addressOffsetXField.cgFloatValue,
				y: addressOffsetYField.cgFloatValue,
				width: addressWidthField.cgFloatValue,
				height: addressHeightField.cgFloatValue
			)
		)
		
		try? pdfDocument?.embedImageAndText(
			image: qrCodeImage,
			at: CGPoint(x: qrCodeOffsetXField.cgFloatValue, y: qrCodeOffsetYField.cgFloatValue),
			texts: [descriptionText, addressText])

		pdfView.document = pdfDocument
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.autoScales = true
		return pdfView
	}

	private func hideKeyboardWhenTappedAround() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc
	private func dismissKeyboard() {
		view.endEditing(true)
	}
}
#endif
