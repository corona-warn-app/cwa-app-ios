//
// 🦠 Corona-Warn-App
//

import UIKit

extension DynamicAction {
	static var safari: Self {
		.execute { _, _ in
			LinkHelper.open(urlString: AppStrings.SafariView.targetURL)
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
			let detailViewController = AppInformationDetailViewController()

			detailViewController.dismissHandling = completion
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

	static func push(htmlModel: HtmlInfoModel, withTitle title: String, completion: (() -> Void)? = nil) -> Self {
		.execute { viewController, _ in
			let htmlViewController = HTMLViewController(model: htmlModel)
			htmlViewController.dismissHandeling = completion
			htmlViewController.title = title
			
			if title == AppStrings.AppInformation.privacyTitle {
				htmlViewController.isDismissable = false
			}
			viewController.navigationController?.pushViewController(htmlViewController, animated: true)
		}
	}
	static func push(viewController toViewController: UIViewController) -> Self {
		.execute { viewController, _ in
			viewController.navigationController?.pushViewController(toViewController, animated: true)
		}
	}
	
	static func pushErrorLogsCoordinator(
		ppacService: PrivacyPreservingAccessControl,
		otpService: OTPServiceProviding
	) -> Self {
		.execute { viewController, _ in
			let coordinator = ErrorReportsCoordinator(
				rootViewController: viewController,
				ppacService: ppacService,
				otpService: otpService
			)
			coordinator.start()
		}
	}
}
