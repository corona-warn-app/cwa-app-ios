import Foundation
import UIKit

class ExposureSubmissionQRInfoViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init

	init(
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void
	) {
		self.viewModel = ExposureSubmissionQRInfoViewModel()
		self.onPrimaryButtonTap = onPrimaryButtonTap

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
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrimaryButtonTap { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonLoading = isLoading
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
			}
		}
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionQRInfoViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.ExposureSubmissionQRInfo.title

		return item
	}()

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}

}
