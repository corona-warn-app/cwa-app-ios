//
//  HomeInfoCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeInfoCellConfigurator: CollectionViewCellConfigurator {
    
    var title: String
    var body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
    
    func configure(cell: InfoCollectionViewCell) {
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = title
        cell.bodyLabel.text = body
    }
}
