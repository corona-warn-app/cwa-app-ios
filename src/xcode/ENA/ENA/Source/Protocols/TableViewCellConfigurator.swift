//
//  TableViewCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol TableViewCellConfiguratorAny {
    var viewAnyType: UITableViewCell.Type { get }
    
    func configureAny(cell: UITableViewCell)
}

protocol TableViewCellConfigurator: TableViewCellConfiguratorAny {
    associatedtype CellType: UITableViewCell
    func configure(cell: CellType)
}

extension TableViewCellConfigurator {
    
    var viewAnyType: UITableViewCell.Type {
        CellType.self
    }
    
    func configureAny(cell: UITableViewCell) {
        if let cell = cell as? CellType {
            configure(cell: cell)
        } else {
            let error = "\(cell) isn't conformed CellType"
            logError(message: error)
            fatalError(error)
        }
    }
}
