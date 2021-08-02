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
		super.init(coder: coder)
		setupView()
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

	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var startButton: ENAButton!
	@IBOutlet private weak var sendReportButton: ENAButton!
	@IBOutlet private weak var saveLocallyButton: ENAButton!
	@IBOutlet private weak var stopAndDeleteButton: ENAButton!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var statusTitle: ENALabel!
	@IBOutlet private weak var statusDescription: ENALabel!
	@IBOutlet private weak var coloredCircle: UIImageView!

	private lazy var fileSizeFormatter: ByteCountFormatter = {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useAll]
		return formatter
	}()
	
	private func setupView() {
		
		titleLabel.text = AppStrings.ErrorReport.analysisTitle

		startButton.setTitle(AppStrings.ErrorReport.startButtonTitle, for: .normal)
		startButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.startButton

		sendReportButton.setTitle(AppStrings.ErrorReport.sendButtontitle, for: .normal)
		sendReportButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.sendReportButton

		saveLocallyButton.setTitle(AppStrings.ErrorReport.saveButtonTitle, for: .normal)
		saveLocallyButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.saveLocallyButton

		stopAndDeleteButton.setTitle(AppStrings.ErrorReport.stopAndDeleteButtonTitle, for: .normal)
		stopAndDeleteButton.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton

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
