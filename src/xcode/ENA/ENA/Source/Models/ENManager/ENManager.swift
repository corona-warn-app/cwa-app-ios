//
//  ENManager.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
import Foundation

final class ENManager {
    static let sharedManager = ExposureNotification.ENManager()

    private init() {}
}
