//
//  NibLoadable.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


protocol NibLoadable: UIView {
	var nibView: UIView! { get }
	var nibName: String { get }
	var nib: UINib { get }
	
	func setupFromNib()
}


extension NibLoadable {
	var nibView: UIView! { self.subviews.first }
	
	var nibName: String { String(describing: type(of: self)) }
	
	var nib: UINib {
		let bundle = Bundle(for: type(of: self))
		return UINib(nibName: nibName, bundle: bundle)
	}
	
	
	func setupFromNib() {
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
}
