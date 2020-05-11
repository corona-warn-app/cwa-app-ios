//
//  RiskLegendTableViewController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

fileprivate let tableViewCellHeight: CGFloat = 200

class RiskLegendTableViewController: UITableViewController {

    let riskLegend = ["unknown", "low", "moderate", "high"]


    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(RiskLegendTableViewCell.self, forCellReuseIdentifier: RiskLegendTableViewCell.identifier)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riskLegend.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RiskLegendTableViewCell.identifier) as? RiskLegendTableViewCell,
            indexPath.row < riskLegend.count else {
            return UITableViewCell()
        }
        cell.titleLabel.text = riskLegend[indexPath.row]
        //cell.titleLabel.text = labels[indexPath.row]

        return cell
    }
}
