//
//  ExposureSubmissionTestResultViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 21.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureSubmissionTestResultViewController: DynamicTableViewController {
    
    // MARK: - Attributes.
    
    var exposureSubmissionService: ExposureSubmissionService?
    var testResult: TestResult?
    
    // MARK: - View Lifecycle methods.
    
	override func viewDidLoad() {
		super.viewDidLoad()
        setupView()
	}
    
    // MARK: - Helper methods.
    
    private func setupView() {
        self.navigationItem.hidesBackButton = true
        
        // TODO: Load the appropriate header view for positive/negative/invalid.
        tableView.register(UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue)
        
        var model: DynamicTableViewModel?
        guard let testResult = testResult else {
            log(message: "No test result.", level: .error)
            return
        }
        
        switch testResult {
        case .positive:
            model = .positive
        case .negative:
            model = .negative
        case .invalid:
            model = .invalid
        case .pending:
            log(message: "ExposureSubmissionTestResultVC should never be opened with status pending", level: .error)
            return
        }
        
        guard let tableViewModel = model else { return }
        dynamicTableViewModel = tableViewModel
    }
}


extension ExposureSubmissionTestResultViewController {
	enum Segue: String, SegueIdentifier {
		case testDetails = "testDetailsSegue"
		case sent = "sentSegue"
	}
}


extension ExposureSubmissionTestResultViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case testResult = "testResultCell"
	}
}


extension ExposureSubmissionTestResultViewController: ExposureSubmissionNavigationControllerChild {
	func didTapBottomButton() {
        guard let testResult = testResult, testResult == .positive else {
            return
        }
        
        let consentConfirmation = ExposureSubmissionViewUtils.setupConfirmationAlert(successAction: self.startSubmitProcess)
        self.present(consentConfirmation, animated: true, completion: nil)
	}
    
    private func startSubmitProcess() {
        exposureSubmissionService?.getTANForExposureSubmit(hasConsent: true, completion: { result in
            switch result {
            case .failure(let error):
                let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
                self.present(alert, animated: true, completion: nil)
            case .success(let tan):
                log(message: "Received tan for submission: \(tan)", level: .info)
                self.submitKeys(with: tan)
            }
        })
    }
    
    private func submitKeys(with tan: String) {
        exposureSubmissionService?.submitExposure(with: tan, completionHandler: { error in
            if let error = error {
                log(message: "error: \(error.localizedDescription)", level: .error)
                let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.performSegue(withIdentifier: Segue.sent, sender: self)
        })
    }
}


private extension DynamicTableViewModel {
	static let positive = DynamicTableViewModel([
		.section(
			header: .identifier(ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult),
			separators: false,
			cells: [
				.semibold(text: "Melden Sie Ihren positiven Befund"),
				.regular(text: "Das Laborergebnis hat einen Nachweis für das Cornavirus SARS-CoV-2 ergeben. Es besteht die Möglichkeit, dass Sie das Virus weiterverbreitet haben. Sie können Ihren Befund anonym melden, damit Kontaktpersonen informiert werden."),
				.icon(text: "Ihr Befund wird anonym übermittelt.", image: UIImage(systemName: "eye"), backgroundColor: .clear, tintColor: .black)
			]
		)
	])
    
    static let negative = DynamicTableViewModel([
        .section(
            header: .text("negative"),
            separators: false,
            cells: [
                .semibold(text: "Test is negative."),
                .regular(text: "NEGATIVE")
            ]
        )
    ])
    
    static let invalid = DynamicTableViewModel([
        .section(
            header: .text("invalid"),
            separators: false,
            cells: [
                .semibold(text: "Test is invalid."),
                .regular(text: "INVALID")
            ]
        )
    ])
}
