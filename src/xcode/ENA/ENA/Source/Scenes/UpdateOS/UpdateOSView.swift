////
// 🦠 Corona-Warn-App
//

import UIKit

class UpdateOSView: UIView {

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	// MARK: - Internal

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .center
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	let logoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .center
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	let titleLabel: ENALabel = {
		let label = ENALabel()
		label.style = .headline
		label.textColor = .enaColor(for: .textPrimary1)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let textLabel: ENALabel = {
		let label = ENALabel()
		label.style = .footnote
		label.textColor = .enaColor(for: .textPrimary2)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Private
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 16
		return stackView
	}()
	
	private let paddingView: UIView = {
		let paddingView = UIView()
		paddingView.backgroundColor = ColorCompatibility.systemBackground
		paddingView.translatesAutoresizingMaskIntoConstraints = false
		return paddingView
	}()
	
	private func setup() {
		backgroundColor = ColorCompatibility.systemBackground
		
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(logoImageView)
		
		// Embedding the text inside a bigger view to get some Padding on the UILabel
		paddingView.addSubview(textLabel)
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(paddingView)
		
		addSubview(imageView)
		scrollView.addSubview(stackView)
		
		addSubview(scrollView)

		NSLayoutConstraint.activate([
			// Logo
			logoImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
			logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
			
			// Center Image
			imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
			imageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
			
			scrollView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
			scrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
			scrollView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			
			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, constant: -88),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			
			textLabel.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: 15),
			textLabel.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -15),
			textLabel.topAnchor.constraint(equalTo: paddingView.topAnchor),
			textLabel.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor)

		])
	}
}
