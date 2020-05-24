//
//  ExposureDetectionViewController+DynamicTableViewModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


extension ExposureDetectionViewController {
	func dynamicTableViewModel(for riskLevel: RiskLevel, isTracingEnabled: Bool) -> DynamicTableViewModel {
		if !isTracingEnabled {
			return offModel
		}
		
		switch riskLevel {
		case .unknown: return unknownRiskModel
		case .inactive: return inactiveRiskModel
		case .low: return lowRiskModel
		case .high: return highRiskModel
		}
	}
}


// MARK: - Supported Cell Types

private extension DynamicTableViewModel.Cell {
	private enum ReusableCellIdentifer: String, TableViewCellReuseIdentifiers {
		case risk = "riskCell"
		case riskText = "riskTextCell"
		case riskRefresh = "riskRefreshCell"
		case header = "headerCell"
		case guide = "guideCell"
		case link = "linkCell"
		case hotline = "hotlineCell"
	}
	
	
	static func risk(_ viewController: ExposureDetectionViewController, configure: @escaping CellConfigurator) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.risk) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			cell.textLabel?.textColor = viewController.state.riskContrastColor
			(cell as? ExposureDetectionRiskCell)?.separatorView.isHidden = (indexPath.row == 0)
			configure(cell, indexPath)
		}
	}
	
	
	static func riskLastRiskLevel(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.riskText)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskContacts(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.numberOfDaysStored ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskLastExposure(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.daysSinceLastExposure ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskStored(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.numberOfDaysStored ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskRefreshed(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			let date = viewController.state.summary?.lastRefreshDate
			cell.textLabel?.text = String(format: text, nil != date ? formatter.string(from: date!) : "Noch nie")
			cell.imageView?.image = image
		}
	}
	
	
	static func riskText(text: String, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.riskText) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			cell.textLabel?.textColor = viewController.state.riskContrastColor
			cell.textLabel?.text = text
		}
	}
	
	
	static func riskRefresh(text: String, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.riskRefresh) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			let components = Calendar.current.dateComponents([.minute, .second], from: Date(), to: viewController.state.nextRefresh!)
			cell.textLabel?.text = String(format: text, components.minute ?? 0, components.second ?? 0)
		}
	}
	
	
	static func header(title: String, subtitle: String) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.header) { cell, indexPath in
			let cell = cell as? ExposureDetectionHeaderCell
			cell?.titleLabel?.text = title
			cell?.subtitleLabel?.text = subtitle
		}
	}
	
	
	static func guide(text: String, image: UIImage?) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.guide) { cell, indexPath in
			cell.textLabel?.text = text
			cell.imageView?.image = image
		}
	}
	
	
	static func link(text: String, url: URL?) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.link, action: .open(url: url)) { cell, indexPath in
			cell.textLabel?.text = text
		}
	}
	
	
	static func hotline(number: String) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.hotline) { cell, indexPath in
			(cell as? InsetTableViewCell)?.insetContentView.primaryAction = {
				if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			}
		}
	}
}


// MARK: - Exposure Detection Model

extension ExposureDetectionViewController {
	private var offModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				footer: .separator(color: .preferredColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)),
				cells: [
					.riskText(text: "Schalten Sie die Risiko-Ermittlung ein, um Ihr Risiko zu aktualisieren.", self),
					.riskLastRiskLevel(text: "Letztes Risiko: %@", image: UIImage(named: "exposure-detection-last-risk-level-contrast"), self),
					.riskRefreshed(text: "Aktualisiert: %@", image: UIImage(named: "exposure-detection-refresh-contrast"), self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Verhalten", subtitle: "So verhalten Sie sich richtig"),
					.guide(text: "Waschen Sie Ihre Hände regelmäßig", image: UIImage(named: "exposure-detection-hands-unknown")),
					.guide(text: "Tragen Sie einen Mundschutz bei Kontakt mit anderen Personen", image: UIImage(named: "exposure-detection-mask-unknown")),
					.guide(text: "Halten Sie mindestens 1,5 Meter Abstand zu anderen Personen", image: UIImage(named: "exposure-detection-distance-unknown")),
					.guide(text: "Niesen oder husten Sie in die Armbeuge oder in ein Taschentuch", image: UIImage(named: "exposure-detection-sneeze-unknown"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Infektionsrisiko", subtitle: "So wird Ihr Risiko ermittelt"),
					.regular(text: "Sie haben ein erhöhtes Infektionsrisiko, da Sie zuletzt vor 2 Tagen mindestens einer Corona positiven Person über einen längeren Zeitpunkt und mit einem geringen Abstand begegnet sind."),
					.regular(text: "Die Infektionswahrscheinlichkeit wird daher als erhöht für Sie eingestuft."),
					.regular(text: "Wenn Sie nach Hause kommen, vermeiden Sie auch den Kontakt zu Familienmitgliedern und Mitbewohnern."),
					.link(text: "Mehr Info", url: URL(string: "https://www.google.de"))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: "0123456789")
				]
			)
		])
	}
	
	private var unknownRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskText(text: "Da Sie die Risiko-Ermittlung noch nicht lange genug aktiviert haben, konnten wir für Sie kein Infektionsrisiko berechnen.", self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Verhalten", subtitle: "So verhalten Sie sich richtig"),
					.guide(text: "Waschen Sie Ihre Hände regelmäßig", image: UIImage(named: "exposure-detection-hands-unknown")),
					.guide(text: "Tragen Sie einen Mundschutz bei Kontakt mit anderen Personen", image: UIImage(named: "exposure-detection-mask-unknown")),
					.guide(text: "Halten Sie mindestens 1,5 Meter Abstand zu anderen Personen", image: UIImage(named: "exposure-detection-distance-unknown")),
					.guide(text: "Niesen oder husten Sie in die Armbeuge oder in ein Taschentuch", image: UIImage(named: "exposure-detection-sneeze-unknown"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Infektionsrisiko", subtitle: "So wird Ihr Risiko ermittelt"),
					.regular(text: "Sie haben ein unbekanntes Infektionsrisiko, da ... Lorem Ipsum ..."),
					.link(text: "Mehr Info", url: URL(string: "https://www.google.de"))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: "0123456789")
				]
			)
		])
	}
	
	private var inactiveRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: "Bisher keine Risiko-Begegnung", image: UIImage(named: "exposure-detection-contacts"), self),
					.riskStored(text: "%d von 14 Tagen gespeichert", image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: "Aktualisiert: %@", image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: "Aktualisierung in %02d:%02d Minuten", self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Verhalten", subtitle: "So verhalten Sie sich richtig"),
					.guide(text: "Waschen Sie Ihre Hände regelmäßig", image: UIImage(named: "exposure-detection-hands-inactive")),
					.guide(text: "Tragen Sie einen Mundschutz bei Kontakt mit anderen Personen", image: UIImage(named: "exposure-detection-mask-inactive")),
					.guide(text: "Halten Sie mindestens 1,5 Meter Abstand zu anderen Personen", image: UIImage(named: "exposure-detection-distance-inactive")),
					.guide(text: "Niesen oder husten Sie in die Armbeuge oder in ein Taschentuch", image: UIImage(named: "exposure-detection-sneeze-inactive"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Infektionsrisiko", subtitle: "So wird Ihr Risiko ermittelt"),
					.regular(text: "Sie haben ein erhöhtes Infektionsrisiko, da Sie zuletzt vor 2 Tagen mindestens einer Corona positiven Person über einen längeren Zeitpunkt und mit einem geringen Abstand begegnet sind."),
					.regular(text: "Die Infektionswahrscheinlichkeit wird daher als erhöht für Sie eingestuft."),
					.regular(text: "Wenn Sie nach Hause kommen, vermeiden Sie auch den Kontakt zu Familienmitgliedern und Mitbewohnern."),
					.link(text: "Mehr Info", url: URL(string: "https://www.google.de"))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: "0123456789")
				]
			)
		])
	}
	
	private var lowRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: "Bisher keine Risiko-Begegnung", image: UIImage(named: "exposure-detection-contacts"), self),
					.riskStored(text: "%d von 14 Tagen gespeichert", image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: "Aktualisiert: %@", image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: "Aktualisierung in %02d:%02d Minuten", self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Verhalten", subtitle: "So verhalten Sie sich richtig"),
					.guide(text: "Waschen Sie Ihre Hände regelmäßig", image: UIImage(named: "exposure-detection-hands-low")),
					.guide(text: "Tragen Sie einen Mundschutz bei Kontakt mit anderen Personen", image: UIImage(named: "exposure-detection-mask-low")),
					.guide(text: "Halten Sie mindestens 1,5 Meter Abstand zu anderen Personen", image: UIImage(named: "exposure-detection-distance-low")),
					.guide(text: "Niesen oder husten Sie in die Armbeuge oder in ein Taschentuch", image: UIImage(named: "exposure-detection-sneeze-low"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Infektionsrisiko", subtitle: "So wird Ihr Risiko ermittelt"),
					.regular(text: "Sie haben ein erhöhtes Infektionsrisiko, da Sie zuletzt vor 2 Tagen mindestens einer Corona positiven Person über einen längeren Zeitpunkt und mit einem geringen Abstand begegnet sind."),
					.regular(text: "Die Infektionswahrscheinlichkeit wird daher als erhöht für Sie eingestuft."),
					.regular(text: "Wenn Sie nach Hause kommen, vermeiden Sie auch den Kontakt zu Familienmitgliedern und Mitbewohnern."),
					.link(text: "Mehr Info", url: URL(string: "https://www.google.de"))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: "0123456789")
				]
			)
		])
	}
	
	private var highRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: "%d Risiko-Begegnungen", image: UIImage(named: "exposure-detection-contacts"), self),
					.riskLastExposure(text: "%d Tage seit der letzten Begegnung", image: UIImage(named: "exposure-detection-calendar"), self),
					.riskStored(text: "%d von 14 Tagen gespeichert", image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: "Aktualisiert: %@", image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: "Aktualisierung in %02d:%02d Minuten", self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Verhalten", subtitle: "So verhalten Sie sich richtig"),
					.guide(text: "Begeben Sie sich umgehend nach Hause bzw. bleiben Sie zu Hause", image: UIImage(named: "exposure-detection-home-high")),
					.guide(text: "Halten Sie mindestens 1,5 Meter Abstand zu anderen Personen", image: UIImage(named: "exposure-detection-distance-high")),
					.guide(text: "Für Fragen zu auftretenden Symptomen, Testmöglichkeiten und weiteren Absonderungsmaßnahmen wenden Sie sich bitte an eine der folgenden Stellen:", image: UIImage(named: "exposure-detection-phone-high"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: "Infektionsrisiko", subtitle: "So wird Ihr Risiko ermittelt"),
					.regular(text: "Sie haben ein erhöhtes Infektionsrisiko, da Sie zuletzt vor 2 Tagen mindestens einer Corona positiven Person über einen längeren Zeitpunkt und mit einem geringen Abstand begegnet sind."),
					.regular(text: "Die Infektionswahrscheinlichkeit wird daher als erhöht für Sie eingestuft."),
					.regular(text: "Wenn Sie nach Hause kommen, vermeiden Sie auch den Kontakt zu Familienmitgliedern und Mitbewohnern."),
					.link(text: "Mehr Info", url: URL(string: "https://www.google.de"))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: "0123456789")
				]
			)
		])
	}
}
