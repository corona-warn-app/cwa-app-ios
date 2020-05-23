//
//  PrivacyProtectionViewController.swift
//  ENA
//
//  Created by Dunne, Liam on 23/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class PrivacyProtectionViewController: UIViewController {

	var blurEffectView: UIVisualEffectView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		view.alpha = 0.0
    }
    
	func setupUI() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
		self.blurEffectView = blurEffectView
        view.insertSubview(blurEffectView, at: 0)

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.masksToBounds = true
        blurEffectView.layer.cornerRadius = 8.0
		
	}

	func show(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: 0.2, animations: {
			self.view.alpha = 1.0
		}, completion: { _ in
			completion?()
		})
	}
	func hide(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: 0.1, animations: {
			self.view.alpha = 0.0
		}, completion: { _ in
			completion?()
		})
	}

}
