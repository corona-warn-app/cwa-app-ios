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
    func setBorder(at edges: UIRectEdge, with color: UIColor, thickness: CGFloat) {
        guard !edges.contains(.all) else {
            addBorder(at: .bottom, with: color, thickness: thickness)
            addBorder(at: .left, with: color, thickness: thickness)
            addBorder(at: .right, with: color, thickness: thickness)
            addBorder(at: .top, with: color, thickness: thickness)
            return
        }
        let allCases = [UIRectEdge.bottom, UIRectEdge.left, UIRectEdge.right, UIRectEdge.top]
        for rectEdge in allCases {
            if edges.contains(rectEdge) {
                addBorder(at: rectEdge, with: color, thickness: thickness)
            }
        }
    }

    //Use additional view in order to set constraints for border layer
    private func addBorder(at rect: UIRectEdge, with color: UIColor, thickness: CGFloat) {

        let layerContainerView = UIView()
        layerContainerView.backgroundColor = color

        switch rect {
        case .top:
            layerContainerView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: thickness)
            insertSubview(layerContainerView, at: 0)
            layerContainerView.translatesAutoresizingMaskIntoConstraints = false
            layerContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            layerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            layerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            layerContainerView.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        case .right:
            layerContainerView.frame = CGRect(x: self.frame.size.width - thickness, y: 0, width: thickness, height: self.frame.size.height)
            insertSubview(layerContainerView, at: 0)
            layerContainerView.translatesAutoresizingMaskIntoConstraints = false
            layerContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            layerContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            layerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            layerContainerView.widthAnchor.constraint(equalToConstant: thickness).isActive = true
        case .bottom:
            layerContainerView.frame = CGRect(x: 0, y: self.frame.size.height - thickness, width: self.frame.size.width, height: thickness)
            insertSubview(layerContainerView, at: 0)
            layerContainerView.translatesAutoresizingMaskIntoConstraints = false
            layerContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            layerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            layerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            layerContainerView.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        case .left:
            layerContainerView.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.size.height)
            insertSubview(layerContainerView, at: 0)
            layerContainerView.translatesAutoresizingMaskIntoConstraints = false
            layerContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            layerContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            layerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            layerContainerView.widthAnchor.constraint(equalToConstant: thickness).isActive = true
        default:
            return
        }
    }
}
