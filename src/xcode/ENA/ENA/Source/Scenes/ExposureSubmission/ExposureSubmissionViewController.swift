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

        titleLabel.text = .title
        descriptionLabel.text = .description
        submitButton.setTitle(.submit, for: .normal)

        navigationItem.title = .navigationBarTitle
    }
}

fileprivate extension String {
    static let title = NSLocalizedString("SelfExposure_Title", comment: "")
    static let description = NSLocalizedString("SelfExposure_Description", comment: "")
    static let submit = NSLocalizedString("SelfExposure_Submit", comment: "")
    static let navigationBarTitle = NSLocalizedString("SelfExposure_Nav_Title", comment: "")
}
