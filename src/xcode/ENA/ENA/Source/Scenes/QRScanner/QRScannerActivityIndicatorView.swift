//
// 🦠 Corona-Warn-App
//

import UIKit

class QRScannerActivityIndicatorView: UIView {

	// MARK: - Init
	
	init(frame: CGRect, title: String) {
		self.title = title
		
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	// MARK: - Private

	private var title: String?

	private func setupView() {
		let overlayView = UIView()
		overlayView.backgroundColor = .init(white: 0.0, alpha: 0.7)
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(overlayView)

		let boxView = UIView()
		boxView.backgroundColor = .enaColor(for: .textContrast)
		boxView.translatesAutoresizingMaskIntoConstraints = false
		boxView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			boxView.layer.cornerCurve = .continuous
		}
		boxView.layer.masksToBounds = true
		overlayView.addSubview(boxView)

		let activityIndicator = UIActivityIndicatorView(style: .gray)
		activityIndicator.hidesWhenStopped = false
		activityIndicator.startAnimating()

		let hudTextLabel = ENALabel(style: .body)
		hudTextLabel.translatesAutoresizingMaskIntoConstraints = false
		hudTextLabel.numberOfLines = 0
		hudTextLabel.textColor = .enaColor(for: .textPrimary1Contrast)
		hudTextLabel.text = title

		let stackView = UIStackView(arrangedSubviews: [activityIndicator, hudTextLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = 8.0
		boxView.addSubview(stackView)

		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
			trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
			topAnchor.constraint(equalTo: overlayView.topAnchor),
			bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
			boxView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -55.0),
			boxView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
			boxView.heightAnchor.constraint(greaterThanOrEqualToConstant: 75.0),
			boxView.widthAnchor.constraint(equalTo: overlayView.widthAnchor, constant: -100),
			stackView.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 25.0),
			stackView.topAnchor.constraint(equalTo: boxView.topAnchor),
			stackView.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -25.0),
			stackView.bottomAnchor.constraint(equalTo: boxView.bottomAnchor)
		])

	}
}
