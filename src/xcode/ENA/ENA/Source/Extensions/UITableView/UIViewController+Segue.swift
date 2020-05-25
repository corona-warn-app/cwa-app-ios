//
//  UIViewController+Segue.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


protocol SegueIdentifiers {
	var rawValue: String { get }
	
	init?(rawValue: String)
	init?(_ string: String)
	init?(_ segue: UIStoryboardSegue)
}


extension SegueIdentifiers {
	init?(_ string: String) {
		self.init(rawValue: string)
	}
	
	init?(_ segue: UIStoryboardSegue) {
		if let identifier = segue.identifier {
			self.init(identifier)
		} else {
			return nil
		}
	}
}


extension UIViewController {
	typealias SegueIdentifier = SegueIdentifiers
	
	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		self.performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}
}
