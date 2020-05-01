//
//  ExposureSubmissionService.swift
//  ENA
//
//  Created by Zildzic, Adnan on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

protocol ExposureSubmissionService {
    typealias ExposureSubmissionHandler = (_ error: Error?) -> Void

    func submitSelfExposure(completionHandler: ExposureSubmissionHandler)
}

class ExposureSubmissionServiceImpl: ExposureSubmissionService {
    func submitSelfExposure(completionHandler: ExposureSubmissionHandler) {
        completionHandler(nil)
    }
}
