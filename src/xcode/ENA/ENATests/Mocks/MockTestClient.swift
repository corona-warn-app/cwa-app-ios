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
    
    func availableDays(completion: @escaping AvailableDaysCompletionHandler) {
        completion(.success([]))
    }

    func availableHours(day: String, completion: @escaping AvailableHoursCompletionHandler) {
        completion(.success([]))
    }

    func fetchDay(_ day: String, completion completeWith: @escaping DayCompletionHandler) {

    }

    func fetchHour(_ hour: Int, day: String, completion completeWith: @escaping HourCompletionHandler) {
        
    }

    let submissionError: SubmissionError?

    init(submissionError: SubmissionError?) {
        self.submissionError = submissionError
    }

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        completion(submissionError)
    }
    
    func getRegistrationToken(forKey key: String, withType type: String, completion completeWith: @escaping RegistrationHandler) {
        completeWith(.success("dummyRegistrationToken"))
    }
    
    func getTestResult(forDevice registrationToken: String, completion completeWith: @escaping TestResultHandler) {
        completeWith(.success(2))
    }
    
    func getTANForExposureSubmit(forDevice registrationToken: String, completion completeWith: @escaping TANHandler) {
        completeWith(.success("dummyTan"))
    }
}
