//
//  AppInformationDetailViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class AppInformationDetailViewController: UITableViewController {
	var model: AppInformationDetailModel!
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationItem.title = model.title
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.content.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellContent = model.content[indexPath.item]
		
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellContent.cellType.rawValue, for: indexPath)
		
		switch cellContent {
		case .headline(let text):
			cell.textLabel?.text = text
		case .body(let text):
			cell.textLabel?.text = text
		case .bold(let text):
			cell.textLabel?.text = text
		case .small(let text):
			cell.textLabel?.text = text
		case .tiny(let text):
			cell.textLabel?.text = text
		case .phone(let text, _):
			cell.textLabel?.text = text
		case .seperator:
			break
		}
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let cellContent = model.content[indexPath.item]
		
		switch cellContent {
		case .phone(_, let number):
			if let url = URL(string: "tel://\(number)") {
				UIApplication.shared.open(url)
			}
		default:
			break
		}
	}
}


extension AppInformationDetailViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case headline = "headlineCell"
		case body = "bodyCell"
		case bold = "boldCell"
		case small = "smallCell"
		case tiny = "tinyCell"
		case phone = "phoneCell"
		case seperator = "separatorCell"
	}
}


private extension AppInformationDetailModel.Content {
	var cellType: AppInformationDetailViewController.ReusableCellIdentifier {
		switch self {
		case .headline:
			return .headline
		case .body:
			return .body
		case .bold:
			return .bold
		case .small:
			return .small
		case .tiny:
			return .tiny
		case .phone:
			return .phone
		case .seperator:
			return .seperator
		}
	}
}
