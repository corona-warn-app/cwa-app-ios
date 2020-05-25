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
	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = .data
		
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue)
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
		performSegue(withIdentifier: Segue.sent, sender: nil)
	}
}


private extension DynamicTableViewModel {
	static let data = DynamicTableViewModel([
		.section(
			header: .identifier(ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult, action: .perform(segue: ExposureSubmissionTestResultViewController.Segue.testDetails)),
			separators: false,
			cells: [
				.semibold(text: "Melden Sie Ihren positiven Befund"),
				.regular(text: "Das Laborergebnis hat einen Nachweis für das Cornavirus SARS-CoV-2 ergeben. Es besteht die Möglichkeit, dass Sie das Virus weiterverbreitet haben. Sie können Ihren Befund anonym melden, damit Kontaktpersonen informiert werden."),
				.icon(text: "Ihr Befund wird anonym übermittelt.", image: UIImage(systemName: "eye"), backgroundColor: .clear, tintColor: .black)
			]
		)
	])
}
