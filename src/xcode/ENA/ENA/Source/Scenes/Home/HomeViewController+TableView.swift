//
//  HomeViewController+TableView.swift
//  ENA
//
//  Created by Dunne, Liam on 20/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

enum TableSection: Int, CaseIterable {
	case infos
	case settings
}
enum TableInfoRow: Int, CaseIterable {
	case share
	case about
}
enum TableSettingRow: Int, CaseIterable {
	case appinfo
	case settings
}

extension HomeViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return TableSection.allCases.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch TableSection(rawValue: section) {
		case .infos: return TableInfoRow.allCases.count
		case .settings: return TableSettingRow.allCases.count
		default: return 0
		}
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

	private func configure(cell: InfoTableViewCell, at indexPath: IndexPath) {
		cell.backgroundColor = UIColor.preferredColor(for: .backgroundBase)

		switch TableSection(rawValue: indexPath.section) {
		case .infos:
			switch TableInfoRow(rawValue: indexPath.row) {
			case .share: cell.configure(with: AppStrings.Home.infoCardShareTitle, and: AppStrings.Home.infoCardShareBody)
			case .about: cell.configure(with: AppStrings.Home.infoCardAboutTitle, and: AppStrings.Home.infoCardAboutBody)
			default: break
			}
		case .settings:
			switch TableSettingRow(rawValue: indexPath.row) {
			case .appinfo: cell.configure(with: AppStrings.Home.appInformationCardTitle)
			case .settings: cell.configure(with: AppStrings.Home.settingsCardTitle)
			default: break
			}
		default:
			break
		}

	}
	
}

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		switch TableSection(rawValue: indexPath.section) {
		case .infos:
			switch TableInfoRow(rawValue: indexPath.row) {
			case .share: showInviteFriends()
			case .about: break //# TODO: implement ÜBER COVID-19 screen here
			default: break
			}
		case .settings:
			switch TableSettingRow(rawValue: indexPath.row) {
			case .appinfo: showAppInformation()
			case .settings: showSetting()
			default: break
			}
		default:
			break
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
