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
		case sentSegue = "sentSegue"
	}
}


extension ExposureSubmissionTanInputViewController: ExposureSubmissionNavigationControllerChild {
	func didTapBottomButton() {
        
        // If teleTAN is correct, show Alert Controller
        // to check permissions to request TAN.
        let teleTan = tanInput.text
        exposureSubmissionService?
            .getRegistrationToken(forKey: .teleTan(teleTan),
                                  completion: { result in
                                    switch result {
                                    case .failure(let error):
                                        self.showErrorAlert(error)
                                        return
                                    case .success:
                                        self.showAlertController(successAction: self.requestTan)
                                    }
        })

	}
    
    /// Show a default error alert.
    private func showErrorAlert(_ error: ExposureSubmissionError) {
        let alert = UIAlertController(title: AppStrings.ExposureSubmission.generalErrorTitle,
                                      message: "\(error.localizedDescription).",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionOk,
                                      style: .cancel,
                                      handler: { _ in
                                        alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func requestTan() {
        exposureSubmissionService?
            .getTANForExposureSubmit(hasConsent: true,
                                     completion: { result in
                                        switch result {
                                        case .failure(let error):
                                            self.showErrorAlert(error)
                                            return
                                        case .success(let tan):
                                            self.submitKeys(withTan: tan)
                                        }
        })
    }
    
    private func submitKeys(withTan tan: String) {
        exposureSubmissionService?
            .submitExposure(with: tan,
                            completionHandler: { error in
                                
                                if error != nil {
                                    //swiftlint:disable:next force_unwrapping
                                    self.showErrorAlert(error!)
                                    return
                                }
                                
                                self.performSegue(withIdentifier: Segue.sentSegue,
                                                  sender: self)
        })
    }
    
    // TODO: Can be refactored by moving to a space
    // where both Tan and QR Code can access this code.
    private func showAlertController(successAction: @escaping (() -> Void)) {
        
        
        let alert = UIAlertController(title: AppStrings.Common.alertTitleKeySubmit,
                                      message: AppStrings.Common.alertDescriptionKeySubmit,
                                      preferredStyle: .alert)
        
        alert
            .addAction(
                UIAlertAction(title: AppStrings.Common.alertActionOk,
                              style: .default,
                              handler: { _ in
                                successAction()
                                alert.dismiss(animated: true,
                                              completion: nil)
                                        
        }))
        
        alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionNo,
                                      style: .cancel,
                                      handler: { _ in
                                        alert.dismiss(animated: true,
                                                      completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
