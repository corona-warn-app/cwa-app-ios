//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class OnBehalfThankYouViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		onDismiss: @escaping () -> Void
	) {
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let viewModel = OnBehalfThankYouViewModel()

	private let onDismiss: () -> Void

	private func setupView() {
		navigationItem.title = AppStrings.OnBehalfCheckinSubmission.ThankYou.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		navigationItem.largeTitleDisplayMode = .always


		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.separatorStyle = .none
	}

}
