////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapContinue: @escaping (@escaping (Bool) -> Void) -> Void,
		didTapDeleteProfile: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = AntigenTestProfileViewModel(store: store)
		self.didTapContinue = didTapContinue
		self.didTapDeleteProfile = didTapDeleteProfile
		self.dismiss = dismiss

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

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.setBackgroundImage(originalBackgroundImage, for: .default)
		navigationController?.navigationBar.shadowImage = originalShadowImage
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		didCalculateGradientHeight = false
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {

		case .primary:
			didTapContinue({ _ in Log.debug("is loading closure here") })
		case .secondary:
			
			let alert = UIAlertController(
				title: AppStrings.AntigenProfile.Profile.deleteAlertTitle,
				message: AppStrings.AntigenProfile.Profile.deleteAlertDescription,
				preferredStyle: .alert
			)
			
			let deleteAction = UIAlertAction(
				title: AppStrings.AntigenProfile.Profile.deleteAlertDeleteButtonTitle,
				style: .destructive,
				handler: { [weak self] _ in
					self?.viewModel.deleteProfile()
					self?.didTapDeleteProfile()
				}
			)
			alert.addAction(deleteAction)
			
			let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
			alert.addAction(cancelAction)
			
			present(alert, animated: true, completion: nil)
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems(in: AntigenTestProfileViewModel.TableViewSection.map(section))
	}

	// MARK: - UITableViewdelegate

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// we are only interested in QRCode cell once if the traitCollectionDidChange - to update gradientHeightConstraint
		guard didCalculateGradientHeight == false,
			  AntigenTestProfileViewModel.TableViewSection.map(indexPath.section)  == .qrCode else {
			return
		}

		let cellRect = tableView.rectForRow(at: indexPath)
		let result = view.convert(cellRect, from: tableView)
		backgroundView.gradientHeightConstraint.constant = result.midY
		didCalculateGradientHeight = true
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch AntigenTestProfileViewModel.TableViewSection.map(indexPath.section) {

		case .header:
			let cell = tableView.dequeueReusableCell(cellType: SimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.headerCellViewModel)
			return cell

		case .qrCode:
			let cell = tableView.dequeueReusableCell(cellType: QRCodeCell.self, for: indexPath)
			cell.configure(with: viewModel.qrCodeCellViewModel)
			return cell

		case .profile:
			let cell = tableView.dequeueReusableCell(cellType: SimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.profileCellViewModel)
			return cell

		case .notice:
			let cell = tableView.dequeueReusableCell(cellType: SimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.noticeCellViewModel)
			return cell
		}
	}

	// MARK: - Private
	
	private let viewModel: AntigenTestProfileViewModel
	private let didTapContinue: (@escaping (Bool) -> Void) -> Void
	private let didTapDeleteProfile: () -> Void
	private let dismiss: () -> Void
	private let backgroundView = GradientBackgroundView(type: .blueOnly)
	private let tableView = UITableView(frame: .zero, style: .plain)

	private var didCalculateGradientHeight: Bool = false
	private var tableContentObserver: NSKeyValueObservation!
	private var originalBackgroundImage: UIImage?
	private var originalShadowImage: UIImage?

	@objc
	private func backToRootViewController() {
		didTapDeleteProfile()
	}

	private func setupNavigationBar() {
		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)

		parent?.navigationController?.navigationBar.tintColor = .white

		parent?.navigationItem.titleView = logoImageView
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton(.contrast)

		// remove previous view controllers from the stack, we will return to the rootViewController by back button here
		navigationController?.viewControllers = [navigationController?.viewControllers.first, navigationController?.viewControllers.last].compactMap { $0 }

		// keep old images for restoration
		originalBackgroundImage = navigationController?.navigationBar.backgroundImage(for: .default)
		originalShadowImage = navigationController?.navigationBar.shadowImage

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
