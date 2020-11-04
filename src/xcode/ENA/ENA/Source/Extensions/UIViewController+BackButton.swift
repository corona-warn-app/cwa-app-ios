import UIKit

extension UIViewController {

	/// Convenience method to set the back button to "Back" / "Zurück".
	func setupBackButton() {
		let backButton = UIBarButtonItem(
			title: AppStrings.Common.general_BackButtonTitle,
			style: .plain,
			target: nil,
			action: nil
		)

		navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
	}
}
