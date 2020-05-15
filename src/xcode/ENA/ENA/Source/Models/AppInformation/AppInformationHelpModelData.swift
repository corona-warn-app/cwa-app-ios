//
//  AppInformationHelpModelData.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation


extension AppInformationHelpModel {
	// TODO: Evalute actual content and localize it
	static let questions = AppInformationHelpModel(
		questions: [
			(
				sectionTitle: "Tracing",
				questions: [
					(title: "Wie funktioniert Tracing?", details: .helpTracing),
					(title: "Wie kann ich das Tracing ausschalten?", details: .helpTracing),
					(title: "Woran erkenne ich, dass das Tracing aktiv ist?", details: .helpTracing)
				]
			),
			(
				sectionTitle: "Meine Daten",
				questions: [
					(title: "Wie lange werden meine Daten gespeichert?", details: .helpTracing),
					(title: "Wie funktioniert die Verschlüsselung meiner Daten?", details: .helpTracing)
				]
			)
		]
	)
}
