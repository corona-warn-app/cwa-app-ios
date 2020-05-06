//
//  SelfExposureViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ExposureSubmissionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = AppStrings.ExposureSubmission.title
        descriptionLabel.text = AppStrings.ExposureSubmission.description
        submitButton.setTitle(AppStrings.ExposureSubmission.submit, for: .normal)

        navigationItem.title = AppStrings.ExposureSubmission.navigationBarTitle
    }
}
