//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class BackgroundAppRefreshViewController: UIViewController {

	// MARK: - Init
	
	init() {
		super.init(nibName: nil, bundle: nil)

		viewModel = BackgroundAppRefreshViewModel(
			onOpenSettings: {
				if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
					UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: nil)
				}
			},
			onShare: { [weak self] in
				if let pdf = self?.contentView.asPDF {
					let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
					self?.present(activityViewController, animated: true, completion: nil)
				}
			}
		)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupBindings()
	}
	
	// MARK: - Private

	private var viewModel: BackgroundAppRefreshViewModel!
    private var subscriptions = Set<AnyCancellable>()
	private let infoBox = InfoBoxView()
	
	@IBOutlet private weak var subTitleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var settingsHeaderLabel: ENALabel!
	@IBOutlet private weak var backgroundAppRefreshTitleLabel: ENALabel!
	@IBOutlet private weak var backgroundAppRefreshStatusLabel: ENALabel!
	@IBOutlet private weak var backgroundAppRefreshStatusStackView: UIStackView!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var contentStackView: UIStackView!
	@IBOutlet private weak var contentView: UIView!
	@IBOutlet private weak var contentScrollView: UIScrollView!
	
	private func setupView() {
		title = viewModel.title
		subTitleLabel.text = viewModel.subTitle
		descriptionLabel.text = viewModel.description
		settingsHeaderLabel.text = viewModel.settingsHeaderTitle
		backgroundAppRefreshTitleLabel.text = viewModel.backgroundAppRefreshTitle

		backgroundAppRefreshStatusStackView.isAccessibilityElement = true
		
		imageView.isAccessibilityElement = true
		imageView.accessibilityIdentifier = AccessibilityIdentifiers.Settings.backgroundAppRefreshImageDescription
	}
	
	private func setupBindings() {
		subscriptions = [
			viewModel.$backgroundAppRefreshStatusText.receive(on: RunLoop.main.ocombine).sink { [weak self] in
				self?.backgroundAppRefreshStatusLabel.text = $0
			},
			viewModel.$backgroundAppRefreshStatusAccessibilityLabel.receive(on: RunLoop.main.ocombine).sink { [weak self] in
				self?.backgroundAppRefreshStatusStackView.accessibilityLabel = $0
			},
			viewModel.$backgroundAppRefreshStatusImageAccessibilityLabel.receive(on: RunLoop.main.ocombine).sink { [weak self] in
				self?.imageView.accessibilityLabel = $0
			},
			viewModel.$image.receive(on: RunLoop.main.ocombine).sink { [weak self] in
					self?.imageView.image = $0
			},
			viewModel.$infoBoxViewModel.receive(on: RunLoop.main.ocombine).sink { [weak self] in
				self?.updateInfoxBox(with: $0)
			}
		]
		
	}
	
	private func updateInfoxBox(with viewModel: InfoBoxViewModel?) {
		if let viewModel = viewModel {
			if infoBox.superview == nil { contentStackView.addArrangedSubview(infoBox) }
			infoBox.update(with: viewModel)
		} else {
			infoBox.removeFromSuperview()

		}
	}

}
