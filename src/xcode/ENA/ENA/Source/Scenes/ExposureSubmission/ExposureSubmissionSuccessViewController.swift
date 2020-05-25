//
//  ExposureSubmissionSuccessViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureSubmissionSuccessViewController: DynamicTableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = .data
	}
	
	
	@IBAction func unwindToExposureSubmissionIntro(_ segue: UIStoryboardSegue) { }
}


private extension DynamicTableViewModel {
	static let data = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "app-information-people")),
			separators: false,
			cells: [
				.semibold(text: "Vielen Dank, dass Sie ihren verifzierten Befund gemeldet haben."),
				.regular(text: "Die pseudonymen Tracing-Daten der letzten 14 Tage wurden übermittelt und Kontakte informiert.")
			]
		)
	])
}
