//
// 🦠 Corona-Warn-App
//

import UIKit

class DMCrashAppViewController: UIViewController {


	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = ColorCompatibility.systemBackground

		let crashButton = UIButton(frame: .zero)
		crashButton.translatesAutoresizingMaskIntoConstraints = false
		crashButton.addTarget(self, action: #selector(crashButtonTaped), for: .touchUpInside)
		crashButton.setTitle("🧨", for: .normal)
		crashButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		
		view.addSubview(crashButton)

		NSLayoutConstraint.activate([
			crashButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			crashButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}


	// MARK: - Private
	
	@objc
	private func crashButtonTaped() {
		let crashAlert = UIAlertController(title: "🚨🚨🚨", message: "Do you really want to crash? 🧨", preferredStyle: .alert)

		let crashAction = UIAlertAction(title: "💥 CRASH BOOM BANG 💥", style: .destructive) { _ in
			fatalError("You wanted it that way.")
		}

		let cancelAction = UIAlertAction(title: "No please don't", style: .cancel)
		crashAlert.addAction(crashAction)
		crashAlert.addAction(cancelAction)
		present(crashAlert, animated: true)
	}
}
