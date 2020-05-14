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
		guard
			let segueIdentifier = segue.identifier,
			let destination = segue.destination as? AppInformationDetailViewController,
			let segue = SegueIdentifier(rawValue: segueIdentifier)
			else { return }
		
		switch segue {
		case .about:
			destination.model = .about
		case .contact:
			destination.model = .contact
		case .help:
			destination.model = .helpTracing
		case .legal:
			destination.model = .legal
		case .privacy:
			destination.model = .privacy
		case .terms:
			destination.model = .terms
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
