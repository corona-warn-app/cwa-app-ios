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

class SubmitCollectionViewCell: UICollectionViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var contactButton: UIButton!
    
    weak var delegate: SubmitCollectionViewCellDelegate?
    
    var submitAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        delegate?.submitButtonTapped(cell: self)
    }

}
