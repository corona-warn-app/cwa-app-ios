//
//  RiskItemTableViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class RiskItemTableViewController: UITableViewController {
    
    private var cellConfigurators: [TableViewCellConfiguratorAny] = []
    
    var titleColor: UIColor?
    var color: UIColor?
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        configureTableView()
    }
    
    // MARK: Methods
    
    func prepareData() {
        let c1 = HomeRiskItemCellConfigurator(title: "title 1", titleColor: titleColor, iconImageName: "Help", color: color)
        let c2 = HomeRiskItemCellConfigurator(title: "title 2", titleColor: titleColor, iconImageName: "History", color: color)
        let c3 = HomeRiskItemCellConfigurator(title: "title 3", titleColor: titleColor, iconImageName: "Home", color: color)
        cellConfigurators = [c1, c2, c3]
    }
    
    func configureTableView() {
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        
        let cellTypes: [UITableViewCell.Type] = [RiskItemTableViewCell.self]
        tableView.register(cellTypes: cellTypes)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellConfigurators.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfigurator = cellConfigurators[indexPath.row]
        let cell = tableView.dequeueReusableCell(cellType: cellConfigurator.viewAnyType, for: indexPath)
        cellConfigurator.configureAny(cell: cell)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
}
