//
//  UIColor.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 02.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public class func preferredColor(for style: ColorStyle, variant: UIUserInterfaceStyle = .light) -> UIColor {
        if let color = preferredColorVariant(for: style) {
            return color
        } else {
            fatalError("Requested color is not available.")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private class func preferredColorVariant(for style: ColorStyle) -> UIColor? {
        switch style {
        case .textPrimary1:
            return UIColor(named: "textPrimary1")
        case .textPrimary2:
            return UIColor(named: "textPrimary2")
        case .textPrimary3:
            return UIColor(named: "textPrimary3")
        case .tintColor:
            return UIColor(red: 0.00, green: 0.53, blue: 0.70, alpha: 1.00)            
        case .separator:
            return UIColor(named: "separator")
        case .hairline:
            return UIColor(named: "hairline")
        case .backgroundBase:
            return UIColor(named: "background")
        case .backgroundContrast:
            return UIColor(named: "backgroundGroup")
        case .positive:
            return UIColor(named: "positive")
        case .negative:
            return UIColor(named: "negative")
        case .medium:
            return UIColor(named: "medium")
        case .unknownRisk:
            return UIColor(named: "unknown")
        case .brandRed:
            return UIColor(named: "brandRed")
        case .brandBlue:
            return UIColor(named: "brandBlue")
        case .brandMagenta:
            return UIColor(named: "brandMagenta")
        }
    }

    func renderImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
        setFill()
        rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
