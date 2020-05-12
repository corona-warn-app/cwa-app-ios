//
//  RiskLegendTableViewController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

class RiskLegendTableViewController: UITableViewController {

    private let tableViewCellHeight: CGFloat = 200

    let riskLegend = RiskLegendFactory.getSharedRiskLegendFactory().getRiskLegend()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.titleLabel.text = riskLegend[indexPath.row].title
        cell.detailTextView.text = riskLegend[indexPath.row].description
        cell.detailTextView.contentInset = .zero
        cell.detailTextView.textContainer.lineFragmentPadding = 0
        cell.iconImageView.image = UIImage(systemName: riskLegend[indexPath.row].imageName)
        cell.iconBackgroundView.backgroundColor = riskLegend[indexPath.row].backgroundColor

        return cell
    }
}
