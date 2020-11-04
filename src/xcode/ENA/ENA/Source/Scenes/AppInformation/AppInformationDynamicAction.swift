extension DynamicAction {
	static var safari: Self {
		.execute { viewController in
			LinkHelper.showWebPage(from: viewController, urlString: AppStrings.SafariView.targetURL)
		}
	}
	
	static func push(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String) -> Self {
		.execute { viewController in
			let detailViewController = AppInformationDetailViewController()
			detailViewController.title = title
			detailViewController.dynamicTableViewModel = model
			detailViewController.separatorStyle = separators ? .singleLine : .none
			viewController.navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
}
