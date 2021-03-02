////
// 🦠 Corona-Warn-App
//

import UIKit

class ErrorReportLoggingViewController: UIViewController {

	// MARK: - Init

	init(
		coordinator: ErrorReportsCoordinating,
		didTapStartButton: @escaping () -> Void,
		didTapSaveButton: @escaping () -> Void,
		didTapSendButton: @escaping () -> Void,
		didTapStopAndDeleteButton: @escaping () -> Void
		) {
		self.coordinator = coordinator
		self.didTapStartButton = didTapStartButton
		self.didTapSaveButton = didTapSaveButton
		self.didTapSendButton = didTapSendButton
		self.didTapStopAndDeleteButton = didTapStopAndDeleteButton

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLable.text = AppStrings.ErrorReport.title
		startButton.setTitle(AppStrings.ErrorReport.startButtonTitle, for: .normal)
		sendReportButton.setTitle(AppStrings.ErrorReport.sendButtontitle, for: .normal)
		saveLocallyButton.setTitle(AppStrings.ErrorReport.saveButtonTitle, for: .normal)
		stopAndDeleteButton.setTitle(AppStrings.ErrorReport.stopAndDeleteButtonTitle, for: .normal)
		configure(status: .inactive)
	}

	// MARK: - Internal

	func configure(status: ErrorLoggingStatus) {
		
		switch status {
		case .active:
			coloredCircle.tintColor = .enaColor(for: .brandRed)
			statusTitle.text = AppStrings.ErrorReport.activeStatustitle
			showButtonsForStatus(isActive: true)

		case .inactive:
			coloredCircle.tintColor = .enaColor(for: .hairline)
			statusTitle.text = AppStrings.ErrorReport.inActiveStatustitle
			showButtonsForStatus(isActive: false)
		}
	}
	
	func updateProgress(progressInBytes: Int) {
		statusDescription.text = String(format: AppStrings.ErrorReport.statusProgress, String(describing: progressInBytes))
	}

	// MARK: - Private

	private func showButtonsForStatus(isActive: Bool) {
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
	
	@IBOutlet private weak var startButton: ENAButton!
	@IBOutlet private weak var sendReportButton: ENAButton!
	@IBOutlet private weak var saveLocallyButton: ENAButton!
	@IBOutlet private weak var stopAndDeleteButton: ENAButton!
	@IBOutlet private weak var titleLable: ENALabel!
	@IBOutlet private weak var statusTitle: ENALabel!
	@IBOutlet private weak var statusDescription: ENALabel!
	@IBOutlet private weak var coloredCircle: UIImageView!
	
	private let didTapStartButton: () -> Void
	private let didTapSaveButton: () -> Void
	private let didTapSendButton: () -> Void
	private let didTapStopAndDeleteButton: () -> Void
	private let coordinator: ErrorReportsCoordinating
}
