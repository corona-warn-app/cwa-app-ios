////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class BottomErrorReportView: UIView {

	// MARK: - Init

	init(
		coordinator: ErrorReportsCoordinating,
		elsService: ErrorLogSubmitting,
		didTapStartButton: @escaping () -> Void,
		didTapSaveButton: @escaping () -> Void,
		didTapSendButton: @escaping () -> Void,
		didTapStopAndDeleteButton: @escaping () -> Void
	) {
		self.coordinator = coordinator
		self.elsService = elsService
		self.didTapStartButton = didTapStartButton
		self.didTapSaveButton = didTapSaveButton
		self.didTapSendButton = didTapSendButton
		self.didTapStopAndDeleteButton = didTapStopAndDeleteButton
		
		super.init(frame: .zero)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal

	func configure(status: ErrorLoggingStatus, animated: Bool = true) {
		switch status {
		case .active:
			coloredCircle.tintColor = .enaColor(for: .brandRed)
			statusTitle.text = AppStrings.ErrorReport.activeStatusTitle
			showButtonsForStatus(isActive: true, animated: animated)

		case .inactive:
			coloredCircle.tintColor = .enaColor(for: .hairline)
			statusTitle.text = AppStrings.ErrorReport.inactiveStatusTitle
			showButtonsForStatus(isActive: false, animated: animated)
		}
	}
	
	func updateProgress(progressInBytes size: Int64) {
		let sizeString = fileSizeFormatter.string(fromByteCount: size)
		statusDescription.text = String(format: AppStrings.ErrorReport.statusProgress, sizeString)
	}

	// MARK: - Private
	
	private let coordinator: ErrorReportsCoordinating
	private let elsService: ErrorLogSubmitting
	private let didTapStartButton: () -> Void
	private let didTapSaveButton: () -> Void
	private let didTapSendButton: () -> Void
	private let didTapStopAndDeleteButton: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var stackView: UIStackView!
	private var startButton: ENAButton!
	private var sendReportButton: ENAButton!
	private var saveLocallyButton: ENAButton!
	private var stopAndDeleteButton: ENAButton!
	private var titleLabel: ENALabel!
	private var statusTitle: ENALabel!
	private var statusDescription: ENALabel!
	private var coloredCircle: UIImageView!

	private lazy var fileSizeFormatter: ByteCountFormatter = {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useAll]
		return formatter
	}()
	
	private func setupView() {
		
		backgroundColor = .enaColor(for: .background)
		
		titleLabel = ENALabel(style: .title2)
		titleLabel.text = AppStrings.ErrorReport.analysisTitle
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		
		let grayView = UIView()
		grayView.backgroundColor = .enaColor(for: .separator)
		grayView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(grayView)
		
		coloredCircle = UIImageView(image: UIImage(named: "icon_fehleranalyse"))
		coloredCircle.tintColor = .enaColor(for: .brandRed)
		coloredCircle.translatesAutoresizingMaskIntoConstraints = false
		grayView.addSubview(coloredCircle)
		
		statusTitle = ENALabel(style: .headline)
		statusTitle.translatesAutoresizingMaskIntoConstraints = false
		grayView.addSubview(statusTitle)
		
		statusDescription = ENALabel(style: .subheadline)
		statusDescription.textColor = .enaColor(for: .textPrimary2)
		statusDescription.translatesAutoresizingMaskIntoConstraints = false
		grayView.addSubview(statusDescription)
		
		stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		
		startButton = ENAButton(frame: .zero)
		startButton.setTitle(AppStrings.ErrorReport.startButtonTitle, for: .normal)
		startButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.startButton
		stackView.addArrangedSubview(startButton)
		
		sendReportButton = ENAButton(frame: .zero)
		sendReportButton.setTitle(AppStrings.ErrorReport.sendButtontitle, for: .normal)
		sendReportButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.sendReportButton
		stackView.addArrangedSubview(sendReportButton)
		
		saveLocallyButton = ENAButton(frame: .zero)
		saveLocallyButton.setTitle(AppStrings.ErrorReport.saveButtonTitle, for: .normal)
		saveLocallyButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.saveLocallyButton
		stackView.addArrangedSubview(saveLocallyButton)
		
		stopAndDeleteButton = ENAButton(frame: .zero)
		stopAndDeleteButton.setTitle(AppStrings.ErrorReport.stopAndDeleteButtonTitle, for: .normal)
		stopAndDeleteButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton
		stackView.addArrangedSubview(stopAndDeleteButton)
		
		NSLayoutConstraint.activate([
			
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			
			grayView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
			grayView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
			grayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			grayView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			grayView.heightAnchor.constraint(equalToConstant: 82),
			
			coloredCircle.widthAnchor.constraint(equalToConstant: 32),
			coloredCircle.heightAnchor.constraint(equalToConstant: 32),
			coloredCircle.centerYAnchor.constraint(equalTo: grayView.centerYAnchor),
			coloredCircle.leadingAnchor.constraint(equalTo: grayView.leadingAnchor, constant: 8),
			coloredCircle.trailingAnchor.constraint(lessThanOrEqualTo: grayView.trailingAnchor, constant: -8),
			
			statusTitle.bottomAnchor.constraint(equalTo: grayView.centerYAnchor, constant: -2),
			statusTitle.leadingAnchor.constraint(equalTo: coloredCircle.trailingAnchor, constant: 8),
			statusTitle.trailingAnchor.constraint(equalTo: grayView.trailingAnchor, constant: -8),
			
			statusDescription.topAnchor.constraint(equalTo: grayView.centerYAnchor, constant: 2),
			statusDescription.leadingAnchor.constraint(equalTo: coloredCircle.trailingAnchor, constant: 8),
			statusDescription.trailingAnchor.constraint(equalTo: grayView.trailingAnchor, constant: -8),
			
			stackView.topAnchor.constraint(equalTo: grayView.bottomAnchor, constant: 16),
			stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
		])
		
		elsService
			.logFileSizePublisher
			.sink { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					Log.error("ELS error: \(error)", log: .els, error: error)
				}
			} receiveValue: { size in
				self.updateProgress(progressInBytes: size)
			}
			.store(in: &subscriptions)
		
		let status: ErrorLoggingStatus = ErrorLogSubmissionService.errorLoggingEnabled ? .active : .inactive
		configure(status: status, animated: false)
	}
	
	private func showButtonsForStatus(isActive: Bool, animated: Bool) {
		startButton.isHidden = isActive
		sendReportButton.isHidden = !isActive
		saveLocallyButton.isHidden = !isActive
		stopAndDeleteButton.isHidden = !isActive
	}
	
	@IBAction private func startLoggingReport(_ sender: Any) {
		didTapStartButton()
		configure(status: .active)
	}
	
	@IBAction private func sendLoggingReport(_ sender: Any) {
		didTapSendButton()
	}
	
	@IBAction private func saveLoggingReport(_ sender: Any) {
		didTapSaveButton()
	}
	
	@IBAction private func stopAndDeleteLoggingReport(_ sender: Any) {
		didTapStopAndDeleteButton()
		configure(status: .inactive)
	}
}
