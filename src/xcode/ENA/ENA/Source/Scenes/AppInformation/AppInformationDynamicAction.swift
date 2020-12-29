//
// 🦠 Corona-Warn-App
//

extension DynamicAction {
	static var safari: Self {
		.execute { viewController, _ in
			LinkHelper.showWebPage(from: viewController, urlString: AppStrings.SafariView.targetURL)
		}
	}

	static func push(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String, completion: (() -> Void)? = nil) -> Self {
		.execute { viewController, _ in
			let detailViewController = AppInformationDetailViewController()
			detailViewController.dismissHandeling = completion
			detailViewController.title = title
			detailViewController.dynamicTableViewModel = model
			detailViewController.separatorStyle = separators ? .singleLine : .none
			viewController.navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
}
