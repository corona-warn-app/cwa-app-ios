//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit
import ExposureNotification


class ExposureDetectionViewController: UIViewController {
	let store: Store
	let client: Client
	let signedPayloadStore: SignedPayloadStore
	
	private var model: ExposureDetectionModel = .unknownRisk
	private var riskLevel: RiskLevel = .unknown
	
	private var exposureDetectionTransaction: ExposureDetectionTransaction?
	private var exposureDetectionSummary: ENExposureDetectionSummary?

	
	@IBOutlet weak var tableView: UITableView!
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
	
	
	init?(coder: NSCoder, store: Store, client: Client, signedPayloadStore: SignedPayloadStore) {
		self.store = store
		self.client = client
		self.signedPayloadStore = signedPayloadStore
		super.init(coder: coder)
	}

	
	@IBAction func tappedClose() {
		self.dismiss(animated: true)
	}
	
	
	@IBAction func tappedCheckNow() {
		log(message: "Starting exposure detection ...")
		self.exposureDetectionTransaction = ExposureDetectionTransaction(delegate: self, client: self.client, signedPayloadStore: self.signedPayloadStore)
		self.exposureDetectionTransaction?.resume()
	}
	
	
	func updateRiskLevel(riskLevel: RiskLevel) {
		self.riskLevel = riskLevel
		self.model = .model(for: riskLevel)
		
		self.tableView.reloadData()
	}
}


extension ExposureDetectionViewController {
	enum Section: Int, CaseIterable {
		case riskLevel
		case content
		case hotline
	}
}


extension ExposureDetectionViewController {
	enum ReusableCellIdentifier: String {
		case risk = "riskCell"
		case headline = "headlineCell"
		case body = "bodyCell"
		case semibold = "semiboldCell"
		case link = "linkCell"
		case guide = "guideCell"
		case phone = "phoneCell"
	}
}


private extension ExposureDetectionModel.Content {
	var cellType: ExposureDetectionViewController.ReusableCellIdentifier {
		switch self {
		case .headline:
			return .headline
		case .guide:
			return .guide
		case .title:
			return .semibold
		case .text:
			return .body
		case .more:
			return .link
		case .phone:
			return .phone
		}
	}
}


extension ExposureDetectionViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .riskLevel:
			return 1
		case .content:
			return model.content.count
		case .hotline:
			return 1
		default:
			return 0
		}
	}

	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .riskLevel, .content:
			return 0
		default:
			return UITableView.automaticDimension
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch Section(rawValue: section) {
		case .riskLevel, .content:
			let view = UIView()
			view.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
			return view
		default:
			return nil
		}
	}

	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .riskLevel:
			return 0
		default:
			return UITableView.automaticDimension
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		switch Section(rawValue: section) {
		case .riskLevel:
			let view = UIView()
			view.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
			return view
		default:
			return nil
		}
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section) {
		case .hotline:
			return model.help
		default:
			return nil
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .riskLevel:
			let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.risk.rawValue, for: indexPath)
			let view = (cell as? ExposureDetectionRiskCell)?.riskView
			view?.configure(
				for: self.riskLevel,
				contacts: Int(exposureDetectionSummary?.matchedKeyCount ?? 0),
				lastExposure: exposureDetectionSummary?.daysSinceLastExposure,
				lastCheck: store.dateLastExposureDetection
			)
			
			return cell
			
		case .content:
			let cellContent = model.content[indexPath.item]
			
			let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellContent.cellType.rawValue, for: indexPath)

			switch cellContent {
			case let .headline(text):
				cell.textLabel?.text = text
			case let .guide(image, text):
				cell.imageView?.image = image
				cell.textLabel?.text = text
			case let .title(text):
				cell.textLabel?.text = text
			case let .text(text):
				cell.textLabel?.text = text
			case let .more(text, _):
				cell.textLabel?.text = text
			case let .phone(text, _):
				cell.textLabel?.text = text
			}
			
			return cell
			
		case .hotline:
			let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.phone.rawValue, for: indexPath)
			cell.textLabel?.text = model.hotline.text
			return cell
			
		default:
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// TODO handle more information
		
		switch Section(rawValue: indexPath.section) {
		case .content:
			switch model.content[indexPath.item] {
			case .more(_, let url):
				if let url = url { UIApplication.shared.open(url) }
			case .phone(_, let number):
				if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			default:
				break
			}
			
		case .hotline:
			if let url = URL(string: "tel://\(model.hotline.number)") {
				UIApplication.shared.open(url)
			}
		default:
			break
		}
	}
}


extension ExposureDetectionViewController: ExposureDetectionTransactionDelegate {
	func exposureDetectionTransaction(_ transaction: ExposureDetectionTransaction, continueWithExposureManager: @escaping ContinueHandler, abort: @escaping AbortHandler) {
		// Important:
		// See HomeViewController for more details as to why we create a new manager here.
		
		let manager = ENAExposureManager()
		manager.activate { error in
			if let error = error {
				let message = "Unable to detect exposures because exposure manager could not be activated due to: \(error)"
				logError(message: message)
				manager.invalidate()
				abort(error)
				// TODO: We should defer abort(…) until the invalidation handler has been called.
				return
			}
			continueWithExposureManager(manager)
		}
	}
	
	func exposureDetectionTransaction(_ transaction: ExposureDetectionTransaction, didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason) {
		// TODO show error to user
		logError(message: "Exposure transaction failed: \(reason)")
		self.exposureDetectionTransaction = nil
	}
	
	func exposureDetectionTransaction(_ transaction: ExposureDetectionTransaction, didDetectSummary summary: ENExposureDetectionSummary) {
		self.exposureDetectionTransaction = nil
		
		self.store.dateLastExposureDetection = Date()

		self.exposureDetectionSummary = summary
		
		self.updateRiskLevel(riskLevel: RiskLevel(riskScore: summary.maximumRiskScore) ?? .unknown)
		
		// Temporarily trigger exposure detection summary notification locally until implemented by transaction flow
		NotificationCenter.default.post(name: .didDetectExposureDetectionSummary, object: nil, userInfo: ["summary": summary])
	}
	
	func exposureDetectionTransactionRequiresFormattedToday(_ transaction: ExposureDetectionTransaction) -> String {
		return .formattedToday()
	}
}
