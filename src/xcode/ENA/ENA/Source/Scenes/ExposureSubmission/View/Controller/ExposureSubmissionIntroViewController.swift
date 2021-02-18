//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionIntroViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init

	init(
		viewModel: ExposureSubmissionIntroViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		footerView?.isHidden = true
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
		footerView?.secondaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.secondaryButton
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Internal

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}

	// MARK: - Private
	
	private let viewModel: ExposureSubmissionIntroViewModel

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.isPrimaryButtonHidden = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.ExposureSubmissionDispatch.title
		item.largeTitleDisplayMode = .automatic

		return item
	}()

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		hidesBottomBarWhenPushed = true
		
		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionImageCardCell.self),
				bundle: nil
			),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableModel
		tableView.separatorStyle = .none

	}
}
