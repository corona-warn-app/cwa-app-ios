//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TanInputViewController: UITableViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: TanInputViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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
		view.backgroundColor = ColorCompatibility.systemBackground
		setupViews()
		setupViewModelBindings()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.tanInputCell.tanInputView.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tanInputCell.tanInputView.resignFirstResponder()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else {
			return 0
		}
		switch section {
		case .one:
			return Row.allCases.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section), let row = Row(rawValue: indexPath.row) else {
			fatalError("This should not happen. Developer error.")
		}
		switch section {
		case .one:
			switch row {
			case .tanInput:
				return tanInputCell
			case .errorLabel:
				return tanErrorCell
			}
		}
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		viewModel.submitTan()
	}
	
	// MARK: - Internal
	
	enum Section: Int, CaseIterable {
		case one
	}
	
	enum Row: Int, CaseIterable {
		case tanInput
		case errorLabel
	}

	// MARK: - Private
	
	private let viewModel: TanInputViewModel
	private let dismiss: () -> Void
	private var bindings: Set<AnyCancellable> = []
	
	private lazy var tanInputCell = TANInputCell(viewModel: viewModel)
	private lazy var tanErrorCell = TANErrorCell(style: .default, reuseIdentifier: TANErrorCell.cellIdentifier)

	private func setupViews() {
		
		parent?.navigationItem.title = AppStrings.ExposureSubmissionTanEntry.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
		
		tableView.register(TANInputCell.self, forCellReuseIdentifier: TANInputCell.cellIdentifier)
		tableView.register(TANErrorCell.self, forCellReuseIdentifier: TANErrorCell.cellIdentifier)
		tableView.separatorStyle = .none
	}

	private func setupViewModelBindings() {
		// viewModel will notify controller to enabled / disabler primary footer button
		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isEnabled in
				self?.footerView?.setEnabled(isEnabled, button: .primary)
			}
			.store(in: &bindings)

		// viewModel will notify controller to enable / disable loadingIndicator on primary footer button
		viewModel.$isPrimaryBarButtonIsLoading
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isLoading in
				guard let self = self else {
					return
				}
				self.footerView?.setLoadingIndicator(isLoading, disable: !self.viewModel.isPrimaryButtonEnabled, button: .primary)
			}
			.store(in: &bindings)

		// viewModel will notify about changes on errorText
		viewModel.$errorText
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] newErrorText in
				Log.debug("viewModel errorText did update to: \(newErrorText)")
				self?.tanErrorCell.errorLabel.text = newErrorText
				// update cell heights and scroll to error cell
				self?.tableView.beginUpdates()
				if !newErrorText.isEmpty {
					self?.tableView.scrollToRow(at: IndexPath(row: Row.errorLabel.rawValue, section: Section.one.rawValue), at: .bottom, animated: true)
				}
				self?.tableView.endUpdates()
			}
			.store(in: &bindings)

		viewModel.didDissMissInvalidTanAlert = { [weak self] in
			self?.footerView?.setLoadingIndicator(false, disable: true, button: .primary)
			self?.tanInputCell.tanInputView.becomeFirstResponder()
		}
	}
}
