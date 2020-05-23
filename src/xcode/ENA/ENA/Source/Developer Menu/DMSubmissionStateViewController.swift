//
//  DMSubmissionStateViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 23.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

protocol DMSubmissionStateViewControllerDelegate: AnyObject {
    func submissionStateViewController(
        _ controller: DMSubmissionStateViewController,
        getDiagnosisKeys: ENGetDiagnosisKeysHandler
    )
}

/// This controller allows you to check if a previous submission of keys successfully ended up in the backend.
final class DMSubmissionStateViewController: UITableViewController {
    init(
        client: Client,
        delegate: DMSubmissionStateViewControllerDelegate
    ) {
        self.client = client
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private weak var delegate: DMSubmissionStateViewControllerDelegate?
    private let client: Client

    // MARK: UIViewController
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = [
            UIBarButtonItem(title: "Do It", style: .plain, target: self, action: #selector(doIt))
        ]
    }

    @objc func doIt() {

    }
}
