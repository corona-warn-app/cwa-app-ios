////
// 🦠 Corona-Warn-App
//
#if !RELEASE

import UIKit

class DMPPACViewController: UITableViewController {

	// MARK: - Init

	init( _ store: Store) {
		#if targetEnvironment(simulator)
		self.viewModel = DMPPCViewModel(store, deviceCheck: PPACDeviceCheckMock(true, deviceToken: "Simulator DeviceCheck unavailable"))
		#else
		self.viewModel = DMPPCViewModel(store, deviceCheck: PPACDeviceCheck())
		#endif

		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupNavigationBar()
		setupTableView()
	}

	// MARK: - Protocol UITableViewDataSource

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// by help of a protocol for cellViewModel we might simplyfiy this even more
		let cellViewModel = viewModel.cellViewModel(by: indexPath)
		if cellViewModel is DMKeyValueCellViewModel {
			let cell = tableView.dequeueReusableCell(cellType: DMKeyValueTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		} else if cellViewModel is DMButtonCellViewModel {
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		} else if cellViewModel is DMStaticTextCellViewModel {
			let cell = tableView.dequeueReusableCell(cellType: DMStaticTextTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		} else {
			fatalError("unsopported cellViewModel - can't find a matching cell")
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows(in: section)
	}

	// MARK: - Private

	private let viewModel: DMPPCViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMKeyValueTableViewCell.self, forCellReuseIdentifier: DMKeyValueTableViewCell.reuseIdentifier)
		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)

		// wire up tableview with the viewModel
		viewModel.refreshTableView = { indexSet in
			DispatchQueue.main.async { [weak self] in
				self?.tableView.reloadSections(indexSet, with: .fade)
			}
		}
	}

	private func setupNavigationBar() {
		title = "PPAC Service 🏄‍♂️"
		let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
		navigationItem.rightBarButtonItem = shareBarButton
	}

	@objc
	private func didTapShareButton() {
		// the device toke gets generated every time, tt's not stored
		guard let deviceToken = viewModel.deviceTokenText else {
			let alert = UIAlertController(
				title: "Missing device token",
				message: "Before sharing please create a device token",
				preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default))
			present(alert, animated: true)
			return
		}
		let activityViewController = UIActivityViewController(activityItems: [deviceToken], applicationActivities: nil)
		present(activityViewController, animated: true)
	}

}
#endif
