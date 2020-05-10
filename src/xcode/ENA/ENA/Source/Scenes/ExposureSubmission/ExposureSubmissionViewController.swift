//
//  SelfExposureViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class ExposureSubmissionViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    var exposureSubmissionService: ExposureSubmissionService?

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = AppStrings.ExposureSubmission.title
        descriptionLabel.text = AppStrings.ExposureSubmission.description
        submitButton.setTitle(AppStrings.ExposureSubmission.submit, for: .normal)

        navigationItem.title = AppStrings.ExposureSubmission.navigationBarTitle
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        precondition(exposureSubmissionService != nil, "`exposureSubmissionService` needs to be set prior submitting.")

        if segue.identifier != "showTanEntry" {
            return
        }

        guard let tanEntryViewController = segue.destination as? TanEntryViewController else {
            return
        }

        tanEntryViewController.exposureSubmissionService = exposureSubmissionService
    }
}
