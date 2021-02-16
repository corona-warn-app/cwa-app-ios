//
// 🦠 Corona-Warn-App
//

import UIKit

extension DynamicAction {
	static var safari: Self {
		.execute { viewController, _ in
			LinkHelper.showWebPage(from: viewController, urlString: AppStrings.SafariView.targetURL)
		}
	}
	
	static func pushDataDonationDetails(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String, completion: (() -> Void)? = nil) -> Self {
		.execute { viewController, _ in
			let detailViewController = DataDonationDetailsViewController()
			detailViewController.tableView.register(
				DynamicTableViewRoundedCell.self,
				forCellReuseIdentifier: DataDonationDetailsViewController.CustomCellReuseIdentifiers.roundedCell.rawValue
			)
			
			detailViewController.dynamicTableViewModel = model
			
			// remove the close button from the navigation controller before pushing the viewController
			guard let navigationController = viewController.navigationController else {
				return
			}
			navigationController.navigationItem.rightBarButtonItem = nil
			navigationController.pushViewController(detailViewController, animated: true)
		}
	}

	static func push(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String, completion: (() -> Void)? = nil) -> Self {
		.execute { viewController, _ in
			let detailViewController: AppInformationDetailViewController
			if title != AppStrings.AppInformation.privacyTitle {
				detailViewController = AppInformationDetailViewController()
			} else {
				detailViewController = DataPrivacyViewControllerDisablingSwipeToDismiss()
			}

			detailViewController.dismissHandeling = completion
			detailViewController.title = title
			detailViewController.dynamicTableViewModel = model
			detailViewController.separatorStyle = separators ? .singleLine : .none
			
			// remove the close button from the navigation controller before pushing the viewController
			guard let navigationController = viewController.navigationController else {
				return
			}
			navigationController.navigationItem.rightBarButtonItem = nil
			navigationController.pushViewController(detailViewController, animated: true)
		}
	}

	static func push(viewController toViewController: UIViewController) -> Self {
		.execute { viewController, _ in
			viewController.navigationController?.pushViewController(toViewController, animated: true)
		}
	}
}
