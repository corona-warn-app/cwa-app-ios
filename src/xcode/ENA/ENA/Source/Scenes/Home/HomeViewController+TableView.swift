//
//  HomeViewController+TableView.swift
//  ENA
//
//  Created by Dunne, Liam on 20/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

extension HomeViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.stringName(), for: indexPath) as? InfoTableViewCell else {
			return UITableViewCell()
		}
		configure(cell: cell, at: indexPath)
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
		view.backgroundColor = .systemGroupedBackground
		return view
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
		view.backgroundColor = .systemGroupedBackground
		return view
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	private func configure(cell: InfoTableViewCell, at indexPath: IndexPath) {
		cell.backgroundColor = UIColor.preferredColor(for: .backgroundBase)

		switch indexPath.section {
		case 0:
			if indexPath.row == 0 {
				cell.configure(with: AppStrings.Home.infoCardShareTitle, and: AppStrings.Home.infoCardShareBody)
            } else {
				cell.configure(with: AppStrings.Home.infoCardAboutTitle, and: AppStrings.Home.infoCardAboutBody)
            }
        case 1:
			if indexPath.row == 0 {
				cell.configure(with: AppStrings.Home.appInformationCardTitle)
            } else {
				cell.configure(with: AppStrings.Home.settingsCardTitle)
            }
		default:
			break
        }
		//resizeDataViews()
	}
	
}

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			if indexPath.row == 0 {
                showInviteFriends()
            } else {
				//# TODO: implement ÜBER COVID-19 screen here
            }
        case 1:
			if indexPath.row == 0 {
				showAppInformation()
            } else {
				showSetting()
            }
		default:
			break
        }
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
