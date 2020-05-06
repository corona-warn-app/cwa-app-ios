//
//  AppInformationViewController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


fileprivate let tableViewCellHeight: CGFloat = 50.0

class AppInformationViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    private let labels = AppStrings.AppInformation.labels

    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self

        tableViewHeightConstraint.constant = CGFloat(labels.count) * tableViewCellHeight
    }
}

extension AppInformationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppInfoTableViewCell.identifier) as? AppInfoTableViewCell,
            indexPath.row < labels.count else {
            return UITableViewCell()
        }
        cell.titleLabel.text = labels[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard indexPath.row < labels.count else {
            return
        }
        let viewController = AppInformationDetailViewController.initiate(for: .appInformation)
        viewController.title = labels[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }

}
