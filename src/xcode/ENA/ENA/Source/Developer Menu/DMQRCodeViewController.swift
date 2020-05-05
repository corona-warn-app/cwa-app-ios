//
//  DMQRCodeViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class DMQRCodeViewController : UIViewController {
    private let key: CodableDiagnosisKey

    init(key: CodableDiagnosisKey) {
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        do {
            let data = try JSONEncoder().encode(key)
            let context = CIContext()
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                return
            }
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            let extent = filter.outputImage!.extent
            let scaled = filter.outputImage!.transformed(by: CGAffineTransform(scaleX: 5.0, y: 5.0))
            let qrCodeCGImage = context.createCGImage(scaled, from: CGRect(origin: .zero, size: CGSize(width: extent.width * 5.0, height: extent.height * 5.0)))!
            let qrCode = UIImage(cgImage: qrCodeCGImage)
            let iv = UIImageView(image: qrCode)
            let view = UIView()
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            view.backgroundColor = .white
            iv.widthAnchor.constraint(equalToConstant: 300).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 300).isActive = true
            view.addSubview(iv)
            self.view = view
        } catch(let error) {
            print(error)
        }
    }
}
