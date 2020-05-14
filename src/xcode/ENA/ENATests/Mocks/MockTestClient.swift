//
//  MockTestClient.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
@testable import ENA

class MockTestClient: Client {
    let submissionError: SubmissionError?

    init(submissionError: SubmissionError?) {
        self.submissionError = submissionError
    }

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        completion(submissionError)
    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {
    }
}
