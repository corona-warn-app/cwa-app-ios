//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class FileScannerHUD {

	// MARK: - Init

	init(
		execute: @escaping () -> Void
	) {
		guard let window = UIApplication.shared.keyWindow else {
			fatalError("Failed to init - not window found")
		}
		self.window = window
		self.hudView = HUDView()
		self.execute = execute

		setupView()
	}

	// MARK: - Internal

	func show() {
		window.isUserInteractionEnabled = false
		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [weak self] in
			self?.hudView.alpha = 1.0
		}
		animator.addCompletion { [weak self] _ in
			self?.execute()
		}
		animator.startAnimation()
	}

	func hide() {
		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [weak self] in
			self?.hudView.alpha = 0.0
		}
		animator.addCompletion { [weak self] _ in
			self?.window.isUserInteractionEnabled = true
			self?.hudView.removeFromSuperview()
		}
		animator.startAnimation()
	}

	// MARK: - Private

	private let window: UIWindow
	private let hudView: HUDView
	private let execute: () -> Void
	private let duration = 0.45

	private func setupView() {
		hudView.translatesAutoresizingMaskIntoConstraints = false
		hudView.isUserInteractionEnabled = false
		window.addSubview(hudView)
		hudView.alpha = 0.0

		NSLayoutConstraint.activate(
			[
				hudView.topAnchor.constraint(equalTo: window.topAnchor),
				hudView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
				hudView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
				hudView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
			]
		)
	}

}
