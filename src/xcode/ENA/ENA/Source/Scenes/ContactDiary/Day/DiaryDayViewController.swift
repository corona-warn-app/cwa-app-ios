////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(
		viewModel: DiaryDayViewModel,
		onInfoButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = viewModel.day.formattedDate

		view.backgroundColor = .enaColor(for: .darkBackground)

		tableView.keyboardDismissMode = .interactive

		setupSegmentedControl()
		setupTableView()

		viewModel.$day
			.sink { [weak self] _ in
				DispatchQueue.main.async {
					self?.updateForSelectedEntryType()
				}
			}
			.store(in: &subscriptions)

		viewModel.$selectedEntryType
			.sink { [weak self] _ in
				// DispatchQueue triggers immediately while .receive(on:) would wait until the main runloop is free, which lead to a crash if the switch happend while scrolling.
				// In that case cells were dequeued for the old model (entriesOfSelectedType) that was not available anymore.
				DispatchQueue.main.async {
					// Scrolling to top prevents table view from flickering while reloading
					self?.tableView.setContentOffset(.zero, animated: false)
					self?.updateForSelectedEntryType()
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return entryAddCell(forRowAt: indexPath)
		case .entries:
			return entryCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			viewModel.didTapAddEntryCell()
		case .entries:
			break
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: DiaryDayViewModel
	private let onInfoButtonTap: () -> Void

	private var subscriptions = [AnyCancellable]()

	@IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
	var day: DiaryDay {
		return viewModel.day
	}

	private func setupSegmentedControl() {
		segmentedControl.setTitle(AppStrings.ContactDiary.Day.contactPersonsSegment, forSegmentAt: 0)
		segmentedControl.setTitle(AppStrings.ContactDiary.Day.locationsSegment, forSegmentAt: 1)
		segmentedControl.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiary.segmentedControl

		// required to make segmented control look a bit like iOS 13
		if #available(iOS 13, *) {
		} else {
			Log.debug("setup segmented control for iOS 12", log: .ui)
			topSpaceConstraint.constant = 8.0
			segmentedControl.tintColor = .enaColor(for: .cellBackground)
			let unselectedBackgroundImage = UIImage.with(color: .enaColor(for: .cellBackground))
			let selectedBackgroundImage = UIImage.with(color: .enaColor(for: .background))

			segmentedControl.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
			segmentedControl.setBackgroundImage(selectedBackgroundImage, for: .selected, barMetrics: .default)
			segmentedControl.setBackgroundImage(selectedBackgroundImage, for: .highlighted, barMetrics: .default)

			segmentedControl.tintAdjustmentMode = .normal

			segmentedControl.layer.borderWidth = 2.5
			segmentedControl.layer.masksToBounds = true
			segmentedControl.layer.cornerRadius = 5.0
			segmentedControl.layer.borderColor = UIColor.enaColor(for: .cellBackground).cgColor
		}

		segmentedControl.setTitleTextAttributes([.font: UIFont.enaFont(for: .subheadline), .foregroundColor: UIColor.enaColor(for: .textPrimary1)], for: .normal)
		segmentedControl.setTitleTextAttributes([.font: UIFont.enaFont(for: .subheadline, weight: .bold), .foregroundColor: UIColor.enaColor(for: .textPrimary1)], for: .selected)
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryDayAddTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayAddTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: DiaryDayEntryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayEntryTableViewCell.self)
		)

		tableView.delegate = self
		tableView.dataSource = self

		tableView.separatorStyle = .none
		tableView.sectionFooterHeight = 0
		tableView.sectionHeaderHeight = 0
		tableView.rowHeight = UITableView.automaticDimension
	}

	private func entryAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayAddTableViewCell.self), for: indexPath) as? DiaryDayAddTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		let cellModel = DiaryDayAddCellModel(entryType: viewModel.selectedEntryType)
		cell.configure(cellModel: cellModel)

		return cell
	}

	private func entryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayEntryTableViewCell.self), for: indexPath) as? DiaryDayEntryTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		let cellModel = viewModel.entryCellModel(at: indexPath)
		cell.configure(
			cellModel: cellModel,
			onInfoButtonTap: { [weak self] in
				self?.onInfoButtonTap()
			}
		)

		return cell
	}

	private func updateForSelectedEntryType() {
				
		if #available(iOS 13, *) {
			tableView.reloadData()
		} else {
			UIView.performWithoutAnimation { [weak self] in
				guard let self = self else {
					return
				}
				let numberOfSections = self.numberOfSections(in: tableView)
				self.tableView.beginUpdates()
				self.tableView.reloadSections(IndexSet(0..<numberOfSections), with: .automatic)
				self.tableView.endUpdates()
			}
		}
		
        tableView.backgroundView = viewModel.entriesOfSelectedType.isEmpty ? EmptyStateView(viewModel: DiaryDayEmptyStateViewModel(entryType: viewModel.selectedEntryType)) : nil
	}

	@IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			viewModel.selectedEntryType = .contactPerson
		default:
			viewModel.selectedEntryType = .location
		}
	}

}
