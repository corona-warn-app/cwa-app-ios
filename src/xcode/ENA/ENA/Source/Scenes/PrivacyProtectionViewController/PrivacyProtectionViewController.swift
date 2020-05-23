//
//  PrivacyProtectionViewController.swift
//  ENA
//
//  Created by Dunne, Liam on 23/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class PrivacyProtectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
		view.alpha = 0.0
    }

	func show() {
		UIView.animate(withDuration: 0.2, animations: {
			self.view.alpha = 1.0
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
