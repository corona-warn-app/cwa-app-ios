// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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
            case let .success(remoteDays):
                days = remoteDays
            case let .failure(error):
                errors.append(error)
            }
            group.leave()
        }

        group.enter()
        availableHours(day: today) { result in
            switch result {
            case let .success(remoteHours):
                hours = remoteHours
            case let .failure(error):
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
            case let .success(daysAndHours):
                self.fetchDays(
                    daysAndHours.days,
                    hours: daysAndHours.hours,
                    of: .formattedToday()
                ) { daysAndHours in
                    completion(daysAndHours)
                }
            case let .failure(error):
                logError(message: "message: Failed to fetch all keys: \(error)")
            }
        }
    }
}
