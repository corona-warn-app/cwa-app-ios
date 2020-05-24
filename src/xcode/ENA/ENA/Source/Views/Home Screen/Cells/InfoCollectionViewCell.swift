//
//  InfoCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
	
	@IBOutlet var topDividerView: UIView!
	@IBOutlet var bottomDividerView: UIView!
	@IBOutlet weak var bottomDividerLeadingConstraint: NSLayoutConstraint!
}
