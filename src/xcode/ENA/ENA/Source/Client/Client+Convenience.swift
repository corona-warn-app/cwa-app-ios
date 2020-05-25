//
//  Client+Convenience.swift
//  ENA
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct DaysAndHoursError: Error {
    let errors: [Error]
}

extension Client {
    typealias DaysAndHours = (days: [String], hours: [Int])
    typealias DaysAndHoursResult = Result<DaysAndHours, DaysAndHoursError>
    typealias DaysAndHoursCompletion = (DaysAndHoursResult) -> Void

    func availableDaysAndHoursUpUntil(
        _ today: String,
        completion: @escaping DaysAndHoursCompletion
    ) {
        let group = DispatchGroup()

        group.enter()

        var days = [String]()
        var hours = [Int]()
        var errors = [Error]()

        availableDays { result in
            switch result {
            case .success(let remoteDays):
                days = remoteDays
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        group.enter()
        availableHours(day: today) { result in
            switch result {
            case .success(let remoteHours):
                hours = remoteHours
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            guard errors.isEmpty else {
                completion(.failure(DaysAndHoursError(errors: errors)))
                return
            }
            completion(.success((days: days, hours: hours)))
        }
    }

    typealias FetchCompletion = (FetchedDaysAndHours) -> Void
    func fetch(completion: @escaping FetchCompletion) {
        availableDaysAndHoursUpUntil(.formattedToday()) { result in
            switch result {
            case .success(let daysAndHours):
                self.fetchDays(
                    daysAndHours.days,
                    hours: daysAndHours.hours,
                    of: .formattedToday()
                ) { daysAndHours in
                    completion(daysAndHours)
                }
            case .failure(let error):
                logError(message: "message: Failed to fetch all keys: \(error)")
            }
        }
    }
}
