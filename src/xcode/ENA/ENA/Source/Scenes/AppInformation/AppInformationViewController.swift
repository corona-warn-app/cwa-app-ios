//
//  AppInformationViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class AppInformationViewController: UITableViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination
		
		guard
			let segueIdentifier = segue.identifier,
			let segue = SegueIdentifier(rawValue: segueIdentifier)
			else { return }
		
		switch segue {
		case .about:
			(destination as? AppInformationDetailViewController)?.model = .about
		case .contact:
			(destination as? AppInformationDetailViewController)?.model = .contact
		case .help:
			(destination as? AppInformationHelpViewController)?.model = .questions
		case .legal:
			(destination as? AppInformationDetailViewController)?.model = .legal
		case .privacy:
			(destination as? AppInformationDetailViewController)?.model = .privacy
		case .terms:
			(destination as? AppInformationDetailViewController)?.model = .terms
		}
	}
}


extension AppInformationViewController {
	private enum SegueIdentifier: String {
		case about = "aboutSegue"
		case contact = "contactSegue"
		case legal = "legalSegue"
		case privacy = "privacySegue"
		case terms = "termsSegue"
		case help = "helpSegue"
	}
}
