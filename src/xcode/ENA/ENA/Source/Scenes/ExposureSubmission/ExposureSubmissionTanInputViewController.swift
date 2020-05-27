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
    
    // MARK: - Attributes.
    
	@IBOutlet weak var tanInput: ENATanInput!
	var initialTan: String?
    var exposureSubmissionService: ExposureSubmissionService?
	
    // MARK: - View lifecycle methods.
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        setupView()
	}
    
    // MARK: - Helper methods.
    
    private func setupView() {
        if let tan = initialTan {
            tanInput.clear()
            tanInput.insertText(tan)
            initialTan = nil
        } else {
            tanInput.becomeFirstResponder()
        }
        
        setButtonTitle(to: AppStrings.ExposureSubmissionTanEntry.submit)
    }
}

// TODO: This extension can be moved to another place
// when the mockups are confirmed.
extension UIViewController {
    func setButtonTitle(to title: String) {
        (navigationController as? ExposureSubmissionNavigationController)?
        .setButtonTitle(title: title)
    }
}


extension ExposureSubmissionTanInputViewController {
	enum Segue: String, SegueIdentifiers {
		case sentSegue = "sentSegue"
	}
}

// MARK: - ExposureSubmissionNavigationControllerChild methods.

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
                                        let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    case .success:
                                        let confirmationAlert = ExposureSubmissionViewUtils
                                            .setupConfirmationAlert(successAction: self.requestTan)
                                        self.present(confirmationAlert, animated: true, completion: nil)
                                    }
        })

	}
    
    private func requestTan() {
        exposureSubmissionService?
            .getTANForExposureSubmit(hasConsent: true,
                                     completion: { result in
                                        switch result {
                                        case .failure(let error):
                                            let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
                                            self.present(alert, animated: true, completion: nil)
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
                                    let alert = ExposureSubmissionViewUtils.setupErrorAlert(error!)
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                                
                                self.performSegue(withIdentifier: Segue.sentSegue,
                                                  sender: self)
        })
    }
}
