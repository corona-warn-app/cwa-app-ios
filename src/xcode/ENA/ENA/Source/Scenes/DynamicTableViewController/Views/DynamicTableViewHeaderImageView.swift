//
//  DynamicTableHeaderCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTableViewHeaderImageView: UITableViewHeaderFooterView {
	private(set) var imageView: UIImageView!
	private var heightConstraint: NSLayoutConstraint!

	
	var image: UIImage? {
		set { imageView.image = newValue }
		get { imageView.image }
	}
	
	var height: CGFloat {
		set { heightConstraint.constant = newValue }
		get { heightConstraint.constant }
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	
	private func setup() {
		imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		
		self.addSubview(imageView)
		imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
		heightConstraint.isActive = true
	}
}
