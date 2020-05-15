//
//  AppInformationHelpViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class AppInformationHelpViewController: UITableViewController {
	var model: AppInformationHelpModel!
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return model.numberOfSections
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return model.title(for: section)
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.questions(in: section).count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let question = model.question(indexPath.row, in: indexPath.section)
		
		let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.question.rawValue, for: indexPath)
		
		cell.textLabel?.text = question.title
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination
		
		guard
			let segueIdentifier = segue.identifier,
			let segue = SegueIdentifier(rawValue: segueIdentifier)
			else { return }
		
		switch segue {
		case .detail:
			(destination as? AppInformationDetailViewController)?.model = .helpTracing
		}
	}
}


extension AppInformationHelpViewController {
	enum SegueIdentifier: String {
		case detail = "detailSegue"
	}
}


extension AppInformationHelpViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case question = "questionCell"
	}
}
