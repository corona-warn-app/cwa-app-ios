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

    var exposureSubmissionService: ExposureSubmissionService

    init?(coder: NSCoder, exposureSubmissionService: ExposureSubmissionService) {
        self.exposureSubmissionService = exposureSubmissionService
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = AppStrings.ExposureSubmission.title
        descriptionLabel.text = AppStrings.ExposureSubmission.description
        submitButton.setTitle(AppStrings.ExposureSubmission.submit, for: .normal)

        navigationItem.title = AppStrings.ExposureSubmission.navigationBarTitle
    }

    @IBSegueAction
    func createTanEntryViewController(coder: NSCoder) -> TanEntryViewController? {
        return TanEntryViewController(coder: coder, exposureSubmissionService: exposureSubmissionService)
    }
}
