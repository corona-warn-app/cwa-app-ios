//
//  DMQRCodeViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

/// A view controller that displays a `DMCodableDiagnosisKey` as a QR code.
final class DMQRCodeViewController : UIViewController {
    // MARK: Creating a Code generating View Controller
    init(key: Key) {
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: Properties
    private let key: Key
    private var PBEncodedKey: Data {
        // This should always work thus we can safely use !
        return try! key.serializedData()
    }

    /// We are reusing the context between instances
    fileprivate static let context = CIContext()

    // MARK: UIViewController
    override func loadView() {
        let filter = CIFilter.QRCodeGeneratingFilter(with: PBEncodedKey)
        let QRCodeImage = UIImage(cgImage: filter.bigOutputCGImage)
        let imageView = UIImageView(image: QRCodeImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Creating the actual view and embedding the image view that displays the QR ode
        let view = UIView()
        view.addSubview(imageView)
        imageView.center(in: view)
        imageView.constrainSize(to: CGSize(width: 300, height: 300))
        view.backgroundColor = .white
        self.view = view
    }
}

fileprivate extension CIFilter {
    class func QRCodeGeneratingFilter(with data: Data) -> CIFilter {
        // We expect there to always be a QR code generator
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        return filter
    }

    private var existingOutputImage: CIImage {
        outputImage!
    }

    private var scaleFactor: CGFloat { 5.0 }

    private var bigOutputImage: CIImage {
        existingOutputImage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
    }

    var bigOutputCGImage: CGImage {
        let extent = existingOutputImage.extent
        return DMQRCodeViewController.context.createCGImage(bigOutputImage, from: CGRect(origin: .zero, size: CGSize(width: extent.width * scaleFactor, height: extent.height * scaleFactor)))!
    }
}

fileprivate extension UIView {
    func constrainSize(to size: CGSize) {
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }

    func center(in view: UIView) {
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
