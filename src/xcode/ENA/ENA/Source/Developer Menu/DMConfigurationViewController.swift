//
//  DMConfigurationViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 17.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class DMConfigurationViewController: UITableViewController {
    // MARK: Creating a Configuration View Controller
    init(distributionURL: String?, submissionURL: String?) {
        self.distributionURL = distributionURL
        self.submissionURL = submissionURL
        super.init(style: .plain)
        title = "Configuration"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    private let distributionURL: String?
    private let submissionURL: String?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            DMConfigurationCell.self,
            forCellReuseIdentifier: DMConfigurationCell.reuseIdentifier
        )
    }
    
    // MARK: UITableViewController
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DMConfigurationCell.reuseIdentifier, for: indexPath)
        let title: String?
        let subtitle: String?
        switch indexPath.row {
        case 0:
            title = "Distribution URL"
            subtitle = distributionURL ?? "<none>"
        case 1:
            title = "Submission URL"
            subtitle = submissionURL ?? "<none>"
        default:
            title = nil
            subtitle = nil
        }
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
}

private class DMConfigurationCell: UITableViewCell {
    static var reuseIdentifier = "DMConfigurationCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
