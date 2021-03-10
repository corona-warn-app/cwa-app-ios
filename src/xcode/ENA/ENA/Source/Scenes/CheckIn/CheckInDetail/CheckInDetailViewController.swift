////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInDetailViewController: UIViewController {

	// MARK: - Init

	init(
		_ checkin: Checkin,
		dismiss: @escaping () -> Void,
		presentCheckIns: @escaping () -> Void
	) {
		self.viewModel = CheckInDetailViewModel(checkin)
		self.dismiss = dismiss
		self.presentCheckIns = presentCheckIns
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}

	// MARK: - Private

	private let viewModel: CheckInDetailViewModel
	private let dismiss: () -> Void
	private let presentCheckIns: () -> Void

	private func setupView() {

		view.backgroundColor = UIColor(white: 0.25, alpha: 0.75)

		let cardView = UIView(frame: .zero)
		cardView.backgroundColor = .enaColor(for: .background)
		cardView.translatesAutoresizingMaskIntoConstraints = false
		cardView.layer.cornerRadius = 15.0
		cardView.layer.masksToBounds = true

		view.addSubview(cardView)

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Event name etc."

		let continueButton = UIButton(type: .custom)
		continueButton.translatesAutoresizingMaskIntoConstraints = false
		continueButton.contentHorizontalAlignment = .leading
		continueButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 24, bottom: 19, right: 24)
		continueButton.setTitle("Weiter", for: .normal)
		continueButton.setTitleColor(.enaColor(for: .textPrimary1), for: .normal)
		let colorImage = UIImage.with(color: .enaColor(for: .buttonPrimary))
		continueButton.setBackgroundImage(colorImage, for: .normal)
		continueButton.layer.cornerRadius = 8.0
		continueButton.layer.masksToBounds = true
		continueButton.addTarget(self, action: #selector(continueButtonHit), for: .primaryActionTriggered)

		let cancelButton = UIButton(type: .custom)
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.contentHorizontalAlignment = .leading
		cancelButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 24, bottom: 19, right: 24)
		cancelButton.setTitle("Abbrechen", for: .normal)
		cancelButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		let cancelColorImage = UIImage.with(color: .enaColor(for: .cellBackground))
		cancelButton.setBackgroundImage(cancelColorImage, for: .normal)
		cancelButton.layer.cornerRadius = 8.0
		cancelButton.layer.masksToBounds = true
		cancelButton.addTarget(self, action: #selector(cancelButtonHit), for: .primaryActionTriggered)

		let stackView = UIStackView(
			arrangedSubviews: [
				label,
				continueButton,
				cancelButton
			]
		)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .fill
		stackView.axis = .vertical
		stackView.spacing = 14
		cardView.addSubview(stackView)

		NSLayoutConstraint.activate([
			cardView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
			cardView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -200),
			cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),

			stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14.0),
			stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 14.0),
			stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
		])
	}

	@objc
	private func continueButtonHit() {
		presentCheckIns()
	}

	@objc
	private func cancelButtonHit() {
		dismiss()
	}

}
