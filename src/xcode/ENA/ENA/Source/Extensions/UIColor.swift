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

        switch variant {
        case .light:
            return preferredColorLightVariant(for: style)
        case .dark:
            return preferredColorDarkVariant(for: style)
        default:
            return preferredColorLightVariant(for: style)
        }
    }

    private class func preferredColorLightVariant(for style: ColorStyle) -> UIColor {
        switch style {
        case .darkText:
            return .darkText
        case .lightText:
            return .lightGray
        case .tintColor:
            return UIColor(red: 0.00, green: 0.53, blue: 0.70, alpha: 1.00)

        case .separator:
            return .systemGray2
        case .border:
            return .systemGray6
        case .shadow:
            return .systemGray3

        case .backgroundBase:
            return systemBackground
        case .backgroundContrast:
            return systemGroupedBackground

        case .positive:
            return .systemGreen
        case .negative:
            return .systemRed
        case .critical:
            return .systemOrange
        }
    }

    private class func preferredColorDarkVariant(for style: ColorStyle) -> UIColor {
        switch style {
        case .darkText:
            return .white
        case .lightText:
            return .lightText
        case .tintColor:
            return .systemBlue

        case .separator:
            return .systemGray2
        case .border:
            return .systemGray6
        case .shadow:
            return .systemGray3

        case .backgroundBase:
            return systemBackground
        case .backgroundContrast:
            return systemGroupedBackground

        case .positive:
            return .systemGreen
        case .negative:
            return .systemRed
        case .critical:
            return .systemOrange

        }
    }

    func renderImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
        setFill()
        rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
