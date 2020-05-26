//
//  ExposureSubmissionIntroViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 19.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


struct ExposureSubmissionTestResult {
	let isPositive: Bool
	let receivedDate: Date
	let transmittedDate: Date?
}


class ExposureSubmissionOverviewViewController: DynamicTableViewController {
    // TODO: Following two lines need to be removed. So far the backend API only gives us 1 int value and no further information.(?)
	private var testResults: [ExposureSubmissionTestResult] = [ExposureSubmissionTestResult(isPositive: true, receivedDate: Date(), transmittedDate: Date())]
	private var mostRecentTestResult: ExposureSubmissionTestResult? { testResults.last }
    
    private var exposureSubmissionService: ExposureSubmissionService?
    
    // MARK: - Initializers.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Move this one screen earlier so we do not even load the ExposureSubmissionOverviewViewController.
        if exposureSubmissionService?.hasRegistrationToken() ?? false {
            fetchResult()
        }
    }
    	
	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = dynamicTableData()
		
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: "test")
        
        // Grab ExposureSubmissionService from the navigation controller
        // (which is the entry point for the storyboard, and in which
        // this controller is embedded.)
        if let navC = navigationController as? ExposureSubmissionNavigationController {
            self.exposureSubmissionService = navC.getExposureSubmissionService()
        }
	}
	
	
	@IBAction func unwindToExposureSubmissionIntro(_ segue: UIStoryboardSegue) { }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch Segue(segue) {
		case .tanInput:
            let destination = segue.destination as? ExposureSubmissionTanInputViewController
            destination?.initialTan = sender as? String
            destination?.exposureSubmissionService = exposureSubmissionService
		case .qrScanner:
            let destination = segue.destination as? ExposureSubmissionQRScannerNavigationController
            destination?.scannerViewController?.delegate = self
            destination?.exposureSubmissionService = exposureSubmissionService
        case .labResult:
            let destination = segue.destination as? ExposureSubmissionTestResultViewController
            destination?.exposureSubmissionService = exposureSubmissionService
            destination?.testResult = sender as? TestResult
		default:
			break
		}
	}
    
    
    private var spinner: UIActivityIndicatorView?
    private func startSpinner() {
        stopSpinner()
        spinner = UIActivityIndicatorView(style: .large)
        guard let spinner = spinner else { return }
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        spinner.startAnimating()
        spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    private func stopSpinner() {
        guard let spinner = spinner else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        self.spinner = nil
    }
}


extension ExposureSubmissionOverviewViewController {
	enum Segue: String, SegueIdentifiers {
		case tanInput = "tanInputSegue"
		case qrScanner = "qrScannerSegue"
		case testDetails = "testDetailsSegue"
        case previousTestResults = "previousTestResultsSegue"
        case labResult = "labResultSegue"
	}
}


extension ExposureSubmissionOverviewViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case test = "test"
	}
}

extension ExposureSubmissionOverviewViewController: ExposureSubmissionQRScannerDelegate {
	func qrScanner(_ viewController: ExposureSubmissionQRScannerViewController, didScan code: String) {
        
        guard let guid = sanitizeAndExtractGuid(code) else {
            // Continue scanning when no valid GUID was extracted.
            return
        }
        
        // Found QR Code, deactivate scanning.
        viewController.delegate = nil
        
        self.exposureSubmissionService?.getRegistrationToken(forKey: .guid(guid), completion: { result in
            switch result {
            case .failure(let error):
                // TODO: Handle error.
                log(message: "Error while getting registration token: \(error)", level: .error)
                self.showAlert("Could not get registration token. \(error.localizedDescription)") {
                    viewController.dismiss(animated: true)
                }
            case .success(let token):
                print("Received registration token: \(token)")
                
                // Dismiss QR code view.
                viewController.dismiss(animated: true)
                self.fetchResult()
            }
        })

	}
        
    private func showAlert(_ message: String, _ completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ok", style: .default, handler: { action in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchResult() {
        startSpinner()
        exposureSubmissionService?.getTestResult { result in
            self.stopSpinner()
            switch result {
            case .failure(let error):
                // TODO: Handle error.
                log(message: "An error occured during result fetching: \(error)", level: .error)
                self.showAlert("An error occured during result fetching: \(error.localizedDescription)")
            case .success(let testResult):
                log(message: "Test Result: \(testResult)", level: .info)
                switch testResult {
                case .pending:
                    self.showAlert("Test Result is pending.")
                default:
                    self.performSegue(withIdentifier: Segue.labResult, sender: testResult)
                }
            }
        }
    }
    
    /// Sanitize the input string and assert that:
    /// - length is smaller than 128 characters
    /// - starts with https://
    /// - contains only alphanumeric characters
    /// - is not empty
    private func sanitizeAndExtractGuid(_ input: String) -> String? {
        guard input.count < 128 else { return nil }
        guard let regex = try? NSRegularExpression(pattern: "^https:\\/\\/.*\\?(?<GUID>[A-Z,a-z,0-9,-]*)") else { return nil }
        guard let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf8.count)) else { return nil }
        let nsRange = match.range(withName: "GUID")
        guard let range = Range(nsRange, in: input) else { return nil }
        let candidate = String(input[range])
        guard !candidate.isEmpty else { return nil }
        return candidate
    }
    
}

private extension ExposureSubmissionOverviewViewController {
	func dynamicTableData() -> DynamicTableViewModel {
		var data = DynamicTableViewModel([])
		
		let header: DynamicTableViewModel.Header
		
	
			header = .image(UIImage(named: "app-information-people"))
		
		data.add(
			.section(
				header: header,
				separators: false,
				cells: [
					.semibold(text: "Wenn Sie einen Covid-19 Test gemacht haben, können Sie sich hier das Testergebnis anzeigen lassen."),
					.regular(text: "Sollte das Testergebnis positiv sein, haben Sie zusätzlich die Möglichkeit Ihren Befund anonym zu melden, damit Kontaktpersonen informiert werden können.")
				]
			)
		)
		
		data.add(
			.section(
				header: .text("Nächste Schritte"),
				cells: [
					.icon(action: .perform(segue: Segue.tanInput), text: "TeleTan eingeben", image: UIImage(systemName: "doc.text"), backgroundColor: .preferredColor(for: .brandBlue), tintColor: .black),
					.icon(action: .perform(segue: Segue.qrScanner), text: "QR-Code scannen", image: UIImage(systemName: "doc.text"), backgroundColor: .preferredColor(for: .brandBlue), tintColor: .black)
				]
			)
		)
		
		data.add(
			.section(
				header: .text("Hilfe"),
				cells: [
					.phone(text: "Hotline anrufen", number: "0123456789")
				]
			)
		)
        if !testResults.isEmpty {
            data.add(
                .section(
                    header: .blank,
                    cells: [
                        .icon(action: .perform(segue: Segue.previousTestResults), text: "Vorherige Testergebnisse", image: UIImage(systemName: "clock"), backgroundColor: .preferredColor(for: .brandBlue), tintColor: .black)
                    ]
                )
            )
        }
		return data
	}
}


private extension DynamicTableViewModel.Cell {
	static func phone(text: String, number: String) -> DynamicTableViewModel.Cell {
		.icon(action: .call(number: number), text: text, image: UIImage(systemName: "phone.fill"), backgroundColor: .preferredColor(for: .brandMagenta), tintColor: .white)
	}
}
