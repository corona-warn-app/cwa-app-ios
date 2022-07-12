//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class ExposureSubmissionIntroViewController: DynamicTableViewController {
	
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
	}

	// MARK: - Internal

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionIntroViewModel

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		navigationItem.title = AppStrings.ExposureSubmissionDispatch.title
		navigationItem.largeTitleDisplayMode = .automatic
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
