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
	
    var exposureSubmissionService: ExposureSubmissionService?
	
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
		case testResult = "testResultSegue"
	}
}


extension ExposureSubmissionTanInputViewController: ExpsureSubmissionNavigationControllerChild {
    
	func didTapBottomButton() {
        
        guard let exposureSubmissionService = self.exposureSubmissionService else {
            logError(message: "ExposureSubmissionService is nil. ")
            return
        }
        
        exposureSubmissionService.submitExposure(tan: "TAN 123456") { error in
            if let error = error {
                logError(message: "Fail to submit tan. Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Segue.testResult, sender: nil)
                }
            }
        }
        
	}
}
