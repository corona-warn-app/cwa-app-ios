//
//  ExposureSubmissionPreviousTestResultsViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 21.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureSubmissionPreviousTestResultsViewController: UITableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
	}
}
