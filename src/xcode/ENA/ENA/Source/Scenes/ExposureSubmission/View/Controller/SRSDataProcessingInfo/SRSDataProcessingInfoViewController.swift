//
// 🦠 Corona-Warn-App
//

import UIKit

class SRSDataProcessingInfoViewController: DynamicTableViewController {
	
	// MARK: - Init
	
	init(
		viewModel: SRSDataProcessingInfoViewModel = .init()
	) {
		self.viewModel = viewModel
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

	// MARK: - Private

	private let viewModel: SRSDataProcessingInfoViewModel
	
	private func setupView() {
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.presentationController?.delegate = self

		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
		
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}

extension SRSDataProcessingInfoViewController: UIAdaptivePresentationControllerDelegate {
	
	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		return false
	}
	
}
