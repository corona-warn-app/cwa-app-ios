//
//  ConfirmationViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = .title
        descriptionLabel.text = .description
        submitButton.setTitle(.submit, for: .normal)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

fileprivate extension String {
    static let title = NSLocalizedString("SelfExposure_Confirmation_Title", comment: "")
    static let description = NSLocalizedString("SelfExposure_Confirmation_Description", comment: "")
    static let submit = NSLocalizedString("SelfExposure_Confirmation_Submit", comment: "")
}
