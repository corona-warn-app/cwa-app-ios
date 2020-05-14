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
    var riskLevel: RiskLevel = .unknown
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        configureTableView()
    }
    
    // MARK: Methods
    
    func prepareData() {
        switch riskLevel {
        case .low:
            break
        case .moderate:
            let c1 = HomeRiskItemCellConfigurator(title: "1 Kontakt", titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let c2 = HomeRiskItemCellConfigurator(title: "12 Tage seit letztem Kontakt", titleColor: titleColor, iconImageName: "Calendar", color: color)
            let c3 = HomeRiskItemCellConfigurator(title: "Letzte Prüfung: Heute, 9:32 Uhr", titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            cellConfigurators = [] //[c1, c2, c3]
        case .high:
            break
        case .unknown:
            break
        }

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
