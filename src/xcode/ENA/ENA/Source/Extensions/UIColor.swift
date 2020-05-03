//
//  UIColor.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 02.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

extension UIColor {
    func renderImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
