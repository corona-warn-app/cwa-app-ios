//
//  UIView.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 08.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

	func setBorder(at edges: [UIRectEdge], with color: UIColor, thickness: CGFloat, and inset: UIEdgeInsets = .zero) {
        if edges.contains(.all) {
			addBorder(at: .bottom, with: color, thickness: thickness, and: inset)
			addBorder(at: .left, with: color, thickness: thickness, and: inset)
			addBorder(at: .right, with: color, thickness: thickness, and: inset)
			addBorder(at: .top, with: color, thickness: thickness, and: inset)
            return
        }
        for rectEdge in edges {
            if edges.contains(rectEdge) {
                addBorder(at: rectEdge, with: color, thickness: thickness, and: inset)
            }
        }
    }

    //Use additional view in order to set constraints for border layer
	private func addBorder(at edge: UIRectEdge, with color: UIColor, thickness: CGFloat, and inset: UIEdgeInsets) {
		let view = UIView()
		insertSubview(view, at: 0)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = color

		switch edge {
		case .top:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.heightAnchor.constraint(equalToConstant: thickness).isActive = true
		case .right:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.widthAnchor.constraint(equalToConstant: thickness).isActive = true
		case .bottom:
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.heightAnchor.constraint(equalToConstant: thickness).isActive = true
		case .left:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.widthAnchor.constraint(equalToConstant: thickness).isActive = true
		default:
            return
        }
    }

}
