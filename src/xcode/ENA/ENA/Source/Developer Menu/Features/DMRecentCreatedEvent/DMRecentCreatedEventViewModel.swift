////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMRecentCreatedEventViewModel {

    // MARK: - Init

    init(
        store: Store
    ) {
        self.store = store
    }

    // MARK: - Internal

    var refreshTableView: (IndexSet) -> Void = { _ in }
    var showAlert: ((UIAlertController) -> Void)?

    var numberOfSections: Int {
        TableViewSections.allCases.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard TableViewSections.allCases.indices.contains(section) else {
            return 0
        }
        // at the moment we assume one cell per section only
        return 1
    }

    func cellViewModel(by indexPath: IndexPath) -> Any {
        guard let section = TableViewSections(rawValue: indexPath.section) else {
            fatalError("Unknown cell requested - stop")
        }

        switch section {
        case .forceSubmission:
            return DMButtonCellViewModel(
                text: "Show recent created event",
                textColor: .white,
                backgroundColor: .enaColor(for: .buttonPrimary),
                action: {
                    
                }
            )
        }
    }

    // MARK: - Private

    private enum TableViewSections: Int, CaseIterable {
        case forceSubmission
    }

    private let store: Store
}
#endif
