//
//  TanEntryViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class TanEntryViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tanTextField: UITextField!

    let service: ExposureSubmissionService = ExposureSubmissionServiceImpl()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = .title
        descriptionLabel.text = .description
        submitButton.setTitle(.submit, for: .normal)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        submitSelfExposure()
    }

    private func submitSelfExposure() {
        guard let tan = tanTextField.text else {
            return
        }

        service.submitSelfExposure(tan: tan) { [weak self] error in
            guard error == nil else {
                //handle error
                return
            }

            self?.loadConfirmationScreen()
        }
    }

    private func loadConfirmationScreen() {
        let confirmationViewController = ConfirmationViewController.initiate(for: .selfExposureConfirmation)
        self.navigationController?.pushViewController(confirmationViewController, animated: true)
    }
}

fileprivate extension String {
    static let title = NSLocalizedString("SelfExposure_TANEntry_Title", comment: "")
    static let description = NSLocalizedString("SelfExposure_TANEntry_Description", comment: "")
    static let submit = NSLocalizedString("SelfExposure_TANEntry_Submit", comment: "")
}
