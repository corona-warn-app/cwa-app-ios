//
//  SelfExposureViewController.swift
//  ENA
//
//  Created by Zildzic, Adnan on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class SelfExposureViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    var exposureSubmissionService: ExposureSubmissionService?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = .title
        descriptionLabel.text = .description
        submitButton.setTitle(.submit, for: .normal)

        navigationItem.title = .navigationBarTitle
    }

    @IBAction func submitClicked(_ sender: Any) {
        let tanEntryViewController = TanEntryViewController.initiate(for: .selfExposureTanEntry)
        precondition(exposureSubmissionService != nil, "`exposureSubmissionService` needs to be set prior submitting.")
        tanEntryViewController.exposureSubmissionService = exposureSubmissionService
        navigationController?.pushViewController(tanEntryViewController, animated: true)
    }
}

fileprivate extension String {
    static let title = NSLocalizedString("SelfExposure_Title", comment: "")
    static let description = NSLocalizedString("SelfExposure_Description", comment: "")
    static let submit = NSLocalizedString("SelfExposure_Submit", comment: "")
    static let navigationBarTitle = NSLocalizedString("SelfExposure_Nav_Title", comment: "")
}
