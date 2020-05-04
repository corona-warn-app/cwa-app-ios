//
//  HomeInfoCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

struct HomeInfoCellConfigurator: CollectionViewCellConfigurator {
    
    var title: String
    var body: String
    
    func configure(cell: InfoCollectionViewCell) {
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = title
        cell.bodyLabel.text = body
    }
}
