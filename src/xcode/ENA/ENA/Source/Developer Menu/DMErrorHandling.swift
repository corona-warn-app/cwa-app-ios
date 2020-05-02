/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Code that displays a UIAlert for a view controller.
*/

import UIKit

func showError(_ error: Error, from viewController: UIViewController) {
    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    viewController.present(alert, animated: true, completion: nil)
}
