//
//  UIView.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 08.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

class ViewBorder: UIView {
	var edge: UIRectEdge
	var color: UIColor
	var thickness: CGFloat
	var inset: UIEdgeInsets
	init(
        edge: UIRectEdge,
        color: UIColor,
        thickness: CGFloat,
        inset: UIEdgeInsets
    ) {
		self.edge = edge
		self.color = color
		self.thickness = thickness
		self.inset = inset
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = color
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(in parentView: UIView) {
		guard parentView == superview else { return }
		
        switch edge {
        case .top:
			topAnchor.constraint(equalTo: parentView.topAnchor, constant: inset.top).isActive = true
			leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: inset.left).isActive = true
			trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: inset.right).isActive = true
			heightAnchor.constraint(equalToConstant: thickness).isActive = true
        case .right:
			topAnchor.constraint(equalTo: parentView.topAnchor, constant: inset.top).isActive = true
			bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: inset.bottom).isActive = true
			trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: inset.right).isActive = true
			widthAnchor.constraint(equalToConstant: thickness).isActive = true
        case .bottom:
			bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: inset.bottom).isActive = true
			leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: inset.left).isActive = true
			trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: inset.right).isActive = true
			heightAnchor.constraint(equalToConstant: thickness).isActive = true
        case .left:
			topAnchor.constraint(equalTo: parentView.topAnchor, constant: inset.top).isActive = true
			bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: inset.bottom).isActive = true
			leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: inset.left).isActive = true
			widthAnchor.constraint(equalToConstant: thickness).isActive = true
        default:
            return
        }
    }
}


extension UIView {

	func clearBorders() {
		subviews.forEach { subview in
			guard let viewBorder = subview as? ViewBorder else { return }
			viewBorder.removeFromSuperview()
		}
	}
	
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
		let viewBorder = ViewBorder(edge: edge, color: color, thickness: thickness, inset: inset)
		insertSubview(viewBorder, at: 0)
		viewBorder.configure(in: self)
    }

}
