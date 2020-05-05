//
//  AppInformationViewController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


fileprivate let tableviewCellHeight: CGFloat = 50.0

class AppInformationViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    private let labels = ["Über die App", "Datenschutz", "Nutzungsbedingungen", "Hotline & Feedback", "Hilfe", "Datenschutz"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableview.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableview.contentSize.height
    }
}

extension AppInformationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableviewCellHeight
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = storyboard?.instantiateViewController(identifier: AppInformationDetailViewController.storyboardID) as? AppInformationDetailViewController,
            indexPath.row < labels.count else {
            return
        }
        viewController.title = labels[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }

}
