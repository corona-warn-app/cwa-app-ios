//
//  ConfirmationViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class ConfirmationViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = AppStrings.ExposureSubmissionConfirmation.title
        descriptionLabel.text = AppStrings.ExposureSubmissionConfirmation.description
        submitButton.setTitle(AppStrings.ExposureSubmissionConfirmation.submit, for: .normal)
    }

    @IBAction func submitTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
