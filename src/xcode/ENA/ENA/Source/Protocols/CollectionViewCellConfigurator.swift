//
//  CollectionViewCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol CollectionViewCellConfiguratorAny: AnyObject {
    var viewAnyType: UICollectionViewCell.Type { get }
    
    func configureAny(cell: UICollectionViewCell)
}

protocol CollectionViewCellConfigurator: CollectionViewCellConfiguratorAny {
    associatedtype CellType: UICollectionViewCell
    func configure(cell: CellType)
}

extension CollectionViewCellConfigurator {
    
    var viewAnyType: UICollectionViewCell.Type {
        CellType.self
    }
    
    func configureAny(cell: UICollectionViewCell) {
        if let cell = cell as? CellType {
            configure(cell: cell)
        } else {
            let error = "\(cell) isn't conformed CellType"
            logError(message: error)
            fatalError(error)
        }
    }
}
