//
// 🦠 Corona-Warn-App
//

import UIKit

class PrivacyProtectionViewController: UIViewController {
	override func loadView() {
		view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .enaColor(for: .background)
		
		if let image = UIImage(named: "Illu_PrivacyProtection_Logo") {
			let imageView = UIImageView(image: image)
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: image.size.width / image.size.height).isActive = true
			
			view.addSubview(imageView)
			view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
			view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
			view.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 375.0 / 100.0).isActive = true
		}
	}
	
	func show() {
		UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
			self.view.alpha = 1.0
		})
	}
	
	func hide(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
			self.view.alpha = 0.0
		}, completion: { _ in
			completion?()
		})
	}
}
