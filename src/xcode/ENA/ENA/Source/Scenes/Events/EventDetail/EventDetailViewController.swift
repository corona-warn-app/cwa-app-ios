////
// 🦠 Corona-Warn-App
//

import UIKit

class EventDetailViewController: UIViewController {

	// MARK: - Init

	init(_ event: String) {
		self.viewModel = EventDetailViewModel(event)
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

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: EventDetailViewModel

	private func setupView() {

		view.backgroundColor = UIColor(white: 0.25, alpha: 0.75)

		let cardView = UIView(frame: .zero)
		cardView.backgroundColor = .enaColor(for: .background)
		cardView.translatesAutoresizingMaskIntoConstraints = false

		cardView.layer.cornerRadius = 15.0
		cardView.layer.masksToBounds = true

		view.addSubview(cardView)
		NSLayoutConstraint.activate([
			cardView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
			cardView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -200),
			cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24)
		])
	}

}
