//
//  SubmitCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol SubmitCollectionViewCellDelegate: AnyObject {
    func submitButtonTapped(cell: SubmitCollectionViewCell)
}

class SubmitCollectionViewCell: HomeCardCollectionViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var contactButton: UIButton!
    
    weak var delegate: SubmitCollectionViewCellDelegate?
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        delegate?.submitButtonTapped(cell: self)
    }

}
