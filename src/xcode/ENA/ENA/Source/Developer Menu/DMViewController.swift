/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller used in debug builds to simulate various app behaviors.
*/

import UIKit
import ExposureNotification
import UserNotifications

class DebugViewController: UITableViewController {

    // MARK: - Table View

    enum Section: Int {
        case general
        case diagnosisKeys
    }

    enum GeneralRow: Int {
        case enableExposureNotifications
        case checkExposureNow
        case simulateExposure
        case simulateUserNotification
        case notifyOthers
        case disableExposureNotifications
        case resetLocalExposures
        case resetLocalTestResults
    }

    enum DiagnosisKeysRow: Int {
        case show
        case reset
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .general:
            switch GeneralRow(rawValue: indexPath.row)! {
            case .enableExposureNotifications:
                enableExposureNotifications()
            case .checkExposureNow:
                checkExposure()
            case .simulateExposure:
                simulateExposure()
            case .simulateUserNotification:
                simulateUserNotification()
            case .notifyOthers:
                notifyOthers()
            case .disableExposureNotifications:
                disableExposureNotifications()
            case .resetLocalExposures:
                resetLocalExposures()
            case .resetLocalTestResults:
                resetLocalTestResults()
            }
        case .diagnosisKeys:
            switch DiagnosisKeysRow(rawValue: indexPath.row)! {
            case .show:
                break // handled by segue
            case .reset:
                resetDiagnosisKeys()
            }
        }
    }

    // MARK: - Enable Exposure Notifications

    func enableExposureNotifications() {
        if ENManager.authorizationStatus == .authorized {
            let alert = UIAlertController(title: "Already Authorized", message: "Exposure Notifications are already enabled.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true, completion: nil)
        } else {
            ExposureManager.shared.manager.setExposureNotificationEnabled(true) { error in
                if let error = error as? ENError, error.code == .notAuthorized {
                    // Encourage the user to consider enabling Exposure Notifications.
                    // Provide a button to allow the user to open Settings to enable it.
                    // Call openSettings() if the user taps the button.
                } else if let error = error {
                    showError(error, from: self)
                } else {
                    self.enablePushNotifications()
                }
            }
        }
    }

    // MARK: - Enable Push Notifications

    func enablePushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Explain to the user that they need to report their diagnosis in the app:
                    //
                    // Submitting your diagnosis is the only way others will be notified if they’ve been exposed.
                    // This app lets you report your diagnosis securely and anonymously. It’s only associated with your random ID — not with any personally identifiable information.
                } else {
                    // Encourage the user to consider enabling Push Notifications so the app can notify the user if they are exposed.
                    // Provide a button to allow the user to open Settings to enable it.
                    // Call openSettings() if the user taps the button.
                }
            }
        }
    }

    // MARK: - Open Settings

    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    // MARK: - Check Exposure

    func checkExposure() {

        let session = ENExposureDetectionSession()
        let batchSize = Int(session.maximumKeyCount)

        func getAllExposures() {
            LocalStore.shared.exposures.removeAll()
            session.getExposureInfo(withMaximumCount: 100) { newExposures, done, error in
                if let error = error {
                    // TODO: Save error to show in exposures tab? Maybe as text under table?
                    showError(error, from: self)
                    return
                }
                LocalStore.shared.exposures.append(contentsOf: newExposures!.map(Exposure.init))
                if done {
                    LocalStore.shared.dateLastPerformedExposureDetection = Date()
                    session.invalidate()
                } else {
                    getAllExposures()
                }
            }
        }

        func finish(_ result: Result<ENExposureDetectionSummary, Error>) {
            switch result {
            case .success:
                getAllExposures()
            case let .failure(error):
                session.invalidate()
                showError(error, from: self)
            }
        }

        /// Get diagnosis keys from server and processes them locally in parallel.
        ///
        /// This diagram shows the sequence of calls, where calls on the second line happen in parallel with the calls above them. Server requests and local processing are rate limited by the slower task.
        /// ```
        ///       | add..... | add.....       | add.... | finishedPositive
        /// get.. | get...   | get........... |
        /// ```
        /// `checkExposure` calls itself recursively until finished. For the above pattern of events, the calls to `checkExposure` would be:
        /// ```
        /// checkExposure(index: 0, diagnosisKeys: nil, done: false) // Kick off the first batch
        /// checkExposure(index: batchSize, diagnosisKeys: [firstBatch], done: false)
        /// checkExposure(index: 2 * batchSize, diagnosisKeys: [secondBatch], done: false)
        /// checkExposure(index: 3 * batchSize, diagnosisKeys: [thirdBatch], done: true)
        /// ```
        /// - Parameter index: The first index of the next batch of keys to fetch from the server.
        /// - Parameter diagnosisKeys: The keys from the last server call to `getDiagnosisKeysResult`.
        /// - Parameter done: Whether the last server call to `getDiagnosisKeysResult` retreived the final batch of keys.
        func checkExposure(index: Int, diagnosisKeys: [ENTemporaryExposureKey]?, done: Bool) {

            let dispatchGroup = DispatchGroup()

            var addPositiveDiagnosisKeysError: Error?
            if let diagnosisKeys = diagnosisKeys {
                dispatchGroup.enter()
                session.addDiagnosisKeys(diagnosisKeys) { error in
                    addPositiveDiagnosisKeysError = error
                    dispatchGroup.leave()
                }
            }

            var getDiagnosisKeysResult: Result<(diagnosisKeys: [ENTemporaryExposureKey], done: Bool), Error>?
            if !done {
                dispatchGroup.enter()
                Server.shared.getDiagnosisKeys(index: index, maximumCount: batchSize) { result in
                    getDiagnosisKeysResult = result
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {

                if let addPositiveDiagnosisKeysError = addPositiveDiagnosisKeysError {
                    finish(.failure(addPositiveDiagnosisKeysError))
                    return
                }

                if let getDiagnosisKeysResult = getDiagnosisKeysResult {
                    switch getDiagnosisKeysResult {
                    case let .success((diagnosisKeys, done)):
                        checkExposure(index: index + batchSize, diagnosisKeys: diagnosisKeys, done: done)
                    case let .failure(error):
                        finish(.failure(error))
                    }
                } else {
                    // If there is no getDiagnosisKeysResult, we're done!
                    session.finishedDiagnosisKeys { summary, error in
                        if let error = error {
                            finish(.failure(error))
                            return
                        }
                        // Assuming summary is non-nil if error is nil
                        finish(.success(summary!))
                    }
                }
            }
        }

        Server.shared.getExposureConfiguration { result in
            switch result {
            case let .success(configuration):
                session.configuration = configuration
                session.activate { error in
                    if let error = error {
                        finish(.failure(error))
                        return
                    }
                    checkExposure(index: 0, diagnosisKeys: nil, done: false)
                }
            case let .failure(error):
                finish(.failure(error))
            }
        }
    }

    // MARK: - Simulation

    func simulateExposure() {
        let riskLevels: [ENRiskLevel] = [.invalid, .lowest, .low, .lowMedium, .medium, .mediumHigh, .high, .veryHigh, .highest]
        let exposure = Exposure(date: Date(),
                                duration: TimeInterval(Int.random(in: 1...5) * 60 * 5),
                                totalRiskScore: ENRiskScore.random(in: 1...8),
                                transmissionRiskLevel: riskLevels.randomElement()!.rawValue)
        LocalStore.shared.exposures.append(exposure)
    }

    func simulateUserNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Possible COVID Exposure"
        content.body = "You may have been exposed to someone who has reported a positive test result for COVID-19"
        content.badge = 1
        content.sound = .default
        let request = UNNotificationRequest(identifier: "exposure", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    showError(error, from: self)
                }
            }
        }
    }

    // MARK: - Notify others

    func notifyOthers() {
        // Collect test results, and get user consent to share their diagnosis before sharing with your server.
        let yesterday = Date().addingTimeInterval(-60 * 60 * 24)
        var testResult = TestResult(dateAdministered: yesterday, dateReceived: Date(), isShared: false)
        ExposureManager.shared.manager.getDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error as? ENError, error.code == .notAuthorized {
                LocalStore.shared.testResults.append(testResult)
            } else if let error = error {
                showError(error, from: self)
            } else {
                Server.shared.postDiagnosisKeys(temporaryExposureKeys ?? []) { error in
                    if let error = error {
                        showError(error, from: self)
                        LocalStore.shared.testResults.append(testResult)
                    } else {
                        testResult.isShared = true
                        LocalStore.shared.testResults.append(testResult)
                    }
                }
            }
        }
    }

    // MARK: - Disable Exposure Notifications

    func disableExposureNotifications() {
        ExposureManager.shared.manager.setExposureNotificationEnabled(false) { error in
            if let error = error {
                showError(error, from: self)
            }
        }
    }

    // MARK: - Reset Local Store

    func resetLocalExposures() {
        LocalStore.shared.exposures = []
        LocalStore.shared.dateLastPerformedExposureDetection = nil
    }

    func resetLocalTestResults() {
        LocalStore.shared.testResults = []
    }

    // MARK: - Reset Server

    func resetDiagnosisKeys() {
        Server.shared.diagnosisKeys = []
    }
}
