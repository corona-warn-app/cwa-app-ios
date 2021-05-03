////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		// add real HealCertificate
		healthCertificate: String,
		dismiss: @escaping () -> Void,
		didTapDelete: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.didTapDelete = didTapDelete
		self.viewModel = HealthCertificateViewModel()
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBackground()
		setupNavigationBar()
		setupTableView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		didCalculateGradientHeight = false
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}
		didTapDelete()
	}

	// MARK: - Protocol UITableViewDateSource

	func numberOfSections(in tableView: UITableView) -> Int {
		HealthCertificatePersonViewModel.TableViewSection.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems(in: HealthCertificateViewModel.TableViewSection.map(section))
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "DummyCell")
		cell.textLabel?.text = "Testcell"
		return cell
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapDelete: () -> Void

	private let viewModel: HealthCertificateViewModel
	private let backgroundView = GradientBackgroundView(type: .blueRedTilted)
	private let tableView = UITableView(frame: .zero, style: .plain)

	private var didCalculateGradientHeight: Bool = false
	private var tableContentObserver: NSKeyValueObservation!

	private func setupNavigationBar() {
		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)

		parent?.navigationController?.navigationBar.tintColor = .white
		parent?.navigationItem.titleView = logoImageView
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton(.contrast)

		// create a transparent navigation bar
		let emptyImage = UIImage()
		navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationController?.navigationBar.shadowImage = emptyImage
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = .clear

		parent?.navigationController?.navigationBar.prefersLargeTitles = false
		parent?.navigationController?.navigationBar.sizeToFit()
		parent?.navigationItem.largeTitleDisplayMode = .never
	}

	private func setupBackground() {
		backgroundView.gradientHeightConstraint.constant = 300.0
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView)

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear

		view.addSubview(tableView)
		NSLayoutConstraint.activate(
			[
				backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
				backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

				tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

			]
		)

		// observer tableView scrolling to move the background in sync
		// y offset value is required
		tableContentObserver = tableView.observe(\UITableView.contentOffset, options: .new) { [weak self] _, change in
			guard let self = self,
				  let yOffset = change.newValue?.y else {
				return
			}
			let offsetLimit = self.view.safeAreaInsets.top
			self.backgroundView.updatedTopLayout(with: yOffset, limit: offsetLimit)
		}
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.register(SimpleTextCell.self, forCellReuseIdentifier: SimpleTextCell.reuseIdentifier)
		tableView.register(QRCodeCell.self, forCellReuseIdentifier: QRCodeCell.reuseIdentifier)
	}

}
