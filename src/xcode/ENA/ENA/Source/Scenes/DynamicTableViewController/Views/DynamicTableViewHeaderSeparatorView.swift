//
//  DynamicTableViewHeaderSeparatorView.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 24.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTableViewHeaderSeparatorView: UITableViewHeaderFooterView {
	private var separatorView: UIView!
	private var heightConstraint: NSLayoutConstraint!

	
	var color: UIColor? {
		set { separatorView.backgroundColor = newValue }
		get { separatorView.backgroundColor }
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
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.layoutMargins = .zero
	}
	
	
	private func setup() {
		self.preservesSuperviewLayoutMargins = false
		self.insetsLayoutMarginsFromSafeArea = false
		self.layoutMargins = .zero
		
		separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(separatorView)
		
		separatorView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
		separatorView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
		separatorView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true

		heightConstraint = separatorView.heightAnchor.constraint(equalToConstant: 1)
		heightConstraint.isActive = true
	}
}
