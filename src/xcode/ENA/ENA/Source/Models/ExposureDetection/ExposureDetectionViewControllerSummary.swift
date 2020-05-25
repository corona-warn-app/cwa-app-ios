//
//  ExposureDetectionViewControllerSummary.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 24.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification


protocol ExposureDetectionViewControllerSummary {
	var numberOfContacts: Int { get }
	var daysSinceLastExposure: Int { get }
	var numberOfDaysStored: Int { get }
	var lastRefreshDate: Date { get }
}


extension ENExposureDetectionSummary: ExposureDetectionViewControllerSummary {
	var numberOfContacts: Int { Int(self.matchedKeyCount) }
	var numberOfDaysStored: Int { .random(in: 0...14) } // TODO Retrieve actual value
	var lastRefreshDate: Date { Date() } // TODO Retrieve actual value
}
