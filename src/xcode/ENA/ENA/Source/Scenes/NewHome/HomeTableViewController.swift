////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeTableViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: HomeTableViewModel,
		onInfoBarButtonItemTap: @escaping () -> Void,
		onExposureDetectionCellTap: @escaping (ENStateHandler.State) -> Void,
		onDiaryCellTap: @escaping () -> Void,
		onInviteFriendsCellTap: @escaping () -> Void,
		onFAQCellTap: @escaping () -> Void,
		onAppInformationCellTap: @escaping () -> Void,
		onSettingsCellTap: @escaping (ENStateHandler.State) -> Void
	) {
		self.viewModel = viewModel

		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onExposureDetectionCellTap = onExposureDetectionCellTap
		self.onDiaryCellTap = onDiaryCellTap
		self.onInviteFriendsCellTap = onInviteFriendsCellTap
		self.onFAQCellTap = onFAQCellTap
		self.onAppInformationCellTap = onAppInformationCellTap
		self.onSettingsCellTap = onSettingsCellTap

		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBarButtonItems()
		setupTableView()

		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = .enaColor(for: .separator)
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			return exposureDetectionCell(forRowAt: indexPath)
		case .diary:
			return diaryCell(forRowAt: indexPath)
		case .infos:
			return infoCell(forRowAt: indexPath)
		case .settings:
			return infoCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView()
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 16
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			onExposureDetectionCellTap(viewModel.state.enState)
		case .diary:
			onDiaryCellTap()
		case .infos:
			if indexPath.row == 0 {
				onInviteFriendsCellTap()
			} else {
				onFAQCellTap()
			}
		case .settings:
			if indexPath.row == 0 {
				onAppInformationCellTap()
			} else {
				onSettingsCellTap(viewModel.state.enState)
			}
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Internal
	func scrollToTop(animated: Bool) {
		tableView.setContentOffset(.zero, animated: animated)
	}
	
	
	// MARK: - Private

	private let onInfoBarButtonItemTap: () -> Void
	private let onExposureDetectionCellTap: (ENStateHandler.State) -> Void
	private let onDiaryCellTap: () -> Void
	private let onInviteFriendsCellTap: () -> Void
	private let onFAQCellTap: () -> Void
	private let onAppInformationCellTap: () -> Void
	private let onSettingsCellTap: (ENStateHandler.State) -> Void

	private let viewModel: HomeTableViewModel

	private func setupBarButtonItems() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Corona-Warn-App"), style: .plain, target: nil, action: nil)
		navigationItem.leftBarButtonItem?.customView = UIImageView(image: navigationItem.leftBarButtonItem?.image)
		navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		navigationItem.leftBarButtonItem?.accessibilityTraits = .none
		navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription

		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: HomeExposureLoggingTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeExposureLoggingTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeDiaryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeDiaryTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeInfoTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func exposureDetectionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeExposureLoggingTableViewCell.self), for: indexPath) as? HomeExposureLoggingTableViewCell else {
			fatalError("Could not dequeue HomeExposureLoggingTableViewCell")
		}

		let cellModel = HomeExposureLoggingCellModel(state: viewModel.state)
		cell.configure(with: cellModel)

		return cell
	}

	private func diaryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeDiaryTableViewCell.self), for: indexPath) as? HomeDiaryTableViewCell else {
			fatalError("Could not dequeue HomeDiaryTableViewCell")
		}

		let cellModel = HomeDiaryCellModel(onPrimaryAction: { [weak self] in
			self?.onDiaryCellTap()
		})
		cell.configure(with: cellModel)

		return cell
	}

	private func infoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeInfoTableViewCell.self), for: indexPath) as? HomeInfoTableViewCell else {
			fatalError("Could not dequeue HomeInfoTableViewCell")
		}

		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .infos:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .inviteFriends))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .faq))
			}
		case .settings:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .appInformation))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .settings))
			}
		default:
			fatalError("Invalid section")
		}

		return cell
	}

	@IBAction private func infoButtonTapped() {
		onInfoBarButtonItemTap()
	}

}
