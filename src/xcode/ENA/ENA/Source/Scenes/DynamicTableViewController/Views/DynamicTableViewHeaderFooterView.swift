//
//  DynamicTableViewHeaderFooterView.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 21.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTableViewHeaderFooterView: UITableViewHeaderFooterView {
	private let tapGestureRecognizer = DynamicTableHeaderFooterViewTapGestureRecognizer()
	
	
	var block: (() -> Void)? {
		set { tapGestureRecognizer.block = newValue }
		get { tapGestureRecognizer.block }
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.gestureRecognizers = [tapGestureRecognizer]
	}
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		tapGestureRecognizer.block = nil
	}
}


private class DynamicTableHeaderFooterViewTapGestureRecognizer: UITapGestureRecognizer {
	var block: (() -> Void)?
	
	init() {
		super.init(target: nil, action: nil)
		self.addTarget(self, action: #selector(didTap))
	}
	
	@objc
	private func didTap() {
		block?()
	}
}
