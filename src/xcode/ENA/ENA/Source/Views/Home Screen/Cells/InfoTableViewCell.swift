//
//  InfoTableViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
	
	func configure(with title: String?, and body: String? = nil) {
		chevronImageView.image = UIImage(systemName: "chevron.right")
		titleLabel.text = title
		bodyLabel.text = body
		bodyLabel.isHidden = (body == nil)
	}
	
}
