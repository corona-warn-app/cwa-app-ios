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

    var exposureSubmissionService: ExposureSubmissionService?

   override func viewDidLoad() {
           super.viewDidLoad()

           titleLabel.text = AppStrings.ExposureSubmissionTanEntry.title
           descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
           submitButton.setTitle(AppStrings.ExposureSubmissionTanEntry.submit, for: .normal)
       }

       @IBAction func submitClicked(_ sender: Any) {
           submitSelfExposure()
       }

    private func submitSelfExposure() {
        guard let tan = tanTextField.text else {
            return
        }

        exposureSubmissionService?.submitSelfExposure(tan: tan) { [weak self] error in
            if error != nil {
                let alert = UIAlertController(title: AppStrings.Commom.alertTitleGeneral, message: AppStrings.Commom.alertMessageGeneral, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: AppStrings.Commom.alertActionOk, style: .default, handler: nil))

                self?.present(alert, animated: true, completion: nil)

                return
            }

            self?.loadConfirmationScreen()
        }
    }

    private func loadConfirmationScreen() {
        let confirmationViewController = ConfirmationViewController.initiate(for: .selfExposureConfirmation)
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }
}
