//
//  ExposureSubmissionTanInputViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 19.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureSubmissionTanInputViewController: UIViewController {
	@IBOutlet weak var tanInput: ENATanInput!
	
	
	var initialTan: String?
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let tan = initialTan {
			tanInput.clear()
			tanInput.insertText(tan)
			initialTan = nil
		} else {
			tanInput.becomeFirstResponder()
		}
	}
}


extension ExposureSubmissionTanInputViewController {
	enum Segue: String, SegueIdentifiers {
		case sentSegue = "sentSegue"
	}
}


extension ExposureSubmissionTanInputViewController: ExpsureSubmissionNavigationControllerChild {
	func didTapBottomButton() {
		performSegue(withIdentifier: Segue.sentSegue, sender: nil)
	}
}
