//
// 🦠 Corona-Warn-App
//

import UIKit
#if DEBUG
import SwiftUI
#endif

class HealthCertifiedPersonReissuanceSucceededViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		didTapEnd: @escaping () -> Void
	) {
		self.didTapEnd = didTapEnd
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		// setup navigation bar
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationController?.navigationBar.prefersLargeTitles = true
		
		setupTableView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		didTapEnd()
	}

	// MARK: - Private

	private let didTapEnd: () -> Void
	private let viewModel = HealthCertifiedPersonReissuanceSucceededViewModel()
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 13.0.0, *)
struct HealthCertifiedPersonReissuanceSucceededViewControllerContainerView: UIViewControllerRepresentable {
	typealias UIViewControllerType = UINavigationController
	func makeUIViewController(context: Context) -> UIViewControllerType {
		return UINavigationController(rootViewController: HealthCertifiedPersonReissuanceSucceededViewController(didTapEnd: {}))
	}
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
@available(iOS 13.0.0, *)
struct ContentViewController_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			HealthCertifiedPersonReissuanceSucceededViewControllerContainerView().colorScheme(.light)
			HealthCertifiedPersonReissuanceSucceededViewControllerContainerView().colorScheme(.dark)
		} // or .dark
	}
}
#endif