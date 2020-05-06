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
            if error != nil {
                let alert = UIAlertController(title: .alertTitleGeneral, message: .alertMessageGeneral, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: .alertActionOk, style: .default, handler: nil))

                self?.present(alert, animated: true, completion: nil)

                return
            }

            self?.loadConfirmationScreen()
        }
    }

    private func loadConfirmationScreen() {
        performSegue(withIdentifier: "ShowConfirmation", sender: nil)
    }
}

fileprivate extension String {
    static let title = NSLocalizedString("SelfExposure_TANEntry_Title", comment: "")
    static let description = NSLocalizedString("SelfExposure_TANEntry_Description", comment: "")
    static let submit = NSLocalizedString("SelfExposure_TANEntry_Submit", comment: "")
    static let alertTitleGeneral = NSLocalizedString("AlertTitleGeneral", comment: "")
    static let alertMessageGeneral = NSLocalizedString("AlertMessageGeneral", comment: "")
    static let alertActionOk = NSLocalizedString("AlertActionOk", comment: "")
}
