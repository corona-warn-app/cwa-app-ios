// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#if !RELEASE

import UIKit

/// A view controller that displays a `Key` as a QR code.
final class DMQRCodeViewController: UIViewController {
	// MARK: Creating a Code generating View Controller

	init(key: SAP_TemporaryExposureKey) {
		self.key = key
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties

	private let key: SAP_TemporaryExposureKey
	private var base64EncodedKey: Data {
		// This should always work thus we can safely use !
		// swiftlint:disable:next force_try
		try! key.serializedData().base64EncodedData()
	}

	/// We are reusing the context between instances
	fileprivate static let context = CIContext()

	// MARK: UIViewController

	override func loadView() {
		let filter = CIFilter.QRCodeGeneratingFilter(with: base64EncodedKey)
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

private extension CIFilter {
	class func QRCodeGeneratingFilter(with data: Data) -> CIFilter {
		// We expect there to always be a QR code generator
		// swiftlint:disable:next force_unwrapping
		let filter = CIFilter(name: "CIQRCodeGenerator")!
		filter.setDefaults()
		log(message: "\(data)")
		filter.setValue(data, forKey: "inputMessage")
		return filter
	}

	private var existingOutputImage: CIImage {
		// swiftlint:disable:next force_unwrapping
		outputImage!
	}

	private var scaleFactor: CGFloat { 5.0 }

	private var bigOutputImage: CIImage {
		existingOutputImage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
	}

	var bigOutputCGImage: CGImage {
		let extent = existingOutputImage.extent
		// swiftlint:disable:next force_unwrapping
		return DMQRCodeViewController.context.createCGImage(bigOutputImage, from: CGRect(origin: .zero, size: CGSize(width: extent.width * scaleFactor, height: extent.height * scaleFactor)))!
	}
}

private extension UIView {
	func constrainSize(to size: CGSize) {
		widthAnchor.constraint(equalToConstant: size.width).isActive = true
		heightAnchor.constraint(equalToConstant: size.height).isActive = true
	}

	func center(in view: UIView) {
		view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
}

#endif
