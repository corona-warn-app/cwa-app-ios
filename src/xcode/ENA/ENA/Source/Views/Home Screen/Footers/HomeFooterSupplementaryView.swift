//
//  HomeFooterSupplementaryView.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeFooterSupplementaryView: UICollectionReusableView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    func configure() {
        // imageView.image =
        containerView.backgroundColor = .systemGroupedBackground
    }
}
