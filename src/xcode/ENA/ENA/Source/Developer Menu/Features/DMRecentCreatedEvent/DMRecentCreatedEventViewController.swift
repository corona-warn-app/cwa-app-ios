////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMRecentCreatedEventViewController: UITableViewController {

    // MARK: - Init

    init(
		store: Store,
		eventStore: EventStoringProviding,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		isPosterGeneration: Bool
    ) {
        self.viewModel = DMRecentCreatedEventViewModel(
            store: store,
            eventStore: eventStore
        )
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.isPosterGeneration = isPosterGeneration
		self.store = store

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

        viewModel.showAlert = { alert in
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        }

        setupNavigationBar()
        setupTableView()
    }

    // MARK: - Protocol UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
		cell.textLabel?.numberOfLines = 0
		cell.detailTextLabel?.numberOfLines = 0
		cell.textLabel?.text = viewModel.titleText(indexPath)
		cell.detailTextLabel?.text = viewModel.detailText(indexPath)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let posterGenerationViewController = DMPosterGenerationViewController(traceLocation: viewModel.traceLocations[indexPath.row], qrCodePosterTemplateProvider: qrCodePosterTemplateProvider, store: store)
		
		DispatchQueue.main.async { [weak self] in
			self?.navigationController?.pushViewController(posterGenerationViewController, animated: true)
		}
	}

    // MARK: - Private

    private let viewModel: DMRecentCreatedEventViewModel
	private let isPosterGeneration: Bool
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let store: Store

    private func setupTableView() {
        tableView.estimatedRowHeight = 45.0
        tableView.rowHeight = UITableView.automaticDimension
		tableView.allowsSelection = isPosterGeneration

        // wire up tableview with the viewModel
        viewModel.refreshTableView = { indexSet in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadSections(indexSet, with: .fade)
            }
        }
    }
	

    private func setupNavigationBar() {
		if isPosterGeneration {
			title = "Select a trace location"
		} else {
			title = "All created trace locations"
		}
    }
}
#endif
