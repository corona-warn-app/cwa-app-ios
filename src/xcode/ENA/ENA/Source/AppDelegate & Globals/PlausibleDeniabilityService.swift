//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol PlausibleDeniability {
	typealias CompletionHandler = () -> Void

	func executeFakeRequests(_ completion: CompletionHandler?)
	func executeFakeRequestOnAppLaunch(probability p: Double) -> Bool
}

struct PlausibleDeniabilityService: PlausibleDeniability {

	init(
		client: Client,
		store: Store,
		coronaTestService: CoronaTestService
	) {
		self.client = client
		self.store = store
		self.coronaTestService = coronaTestService

		fakeRequestService = FakeRequestService(client: client)
	}

	// MARK: - Internal

	/// Trigger a fake playbook to enable plausible deniability.
	func executeFakeRequests(_ completion: (() -> Void)? = nil) {
		guard isAllowedToPerformBackgroundFakeRequests else {
			completion?()
			return
		}

		// Initialize firstPlaybookExecution date during the first run regardless of actual execution.
		if store.firstPlaybookExecution == nil {
			store.firstPlaybookExecution = Date()
		}

		// Time interval until we want to resend a fake request from the background.
		let offset = Double.random(in: Constants.minHoursToNextBackgroundExecution...Constants.maxHoursToNextBackgroundExecution) * 60
		let now = Date()

		if
			let firstPlaybookExecution = store.firstPlaybookExecution,
			firstPlaybookExecution.addingTimeInterval(Constants.numberOfDaysToRunPlaybook * Constants.secondsPerDay) > now,
			store.lastBackgroundFakeRequest.addingTimeInterval(offset) > now
		{
			sendFakeRequest {
				self.store.lastBackgroundFakeRequest = now
				completion?()
			}
		} else {
			completion?()
		}
	}

	/// Randomly execute a fake request
	/// - Parameter probability: the probability p to execute a fake request. Accepting values between 0 and 1.
	/// - Returns: Bool to indicate wether the fake request has been sent
	@discardableResult
	func executeFakeRequestOnAppLaunch(probability p: Double) -> Bool {
		assert(p <= 1, "p should be lower than or equal 1.0")
		assert(p >= 0, "p should be greater than or equal 0.0")
		if Double.random(in: 0.0.nextUp...1) <= p {
			sendFakeRequest()
			return true
		}
		return false
	}

	// MARK: - Private

	private enum Constants {
		static let minHoursToNextBackgroundExecution = 0.0
		static let maxHoursToNextBackgroundExecution = 0.0
		static let numberOfDaysToRunPlaybook = 0.0
		static let minNumberOfSequentialPlaybooks = 0
		static let maxNumberOfSequentialPlaybooks = 0
		/// In seconds
		static let minDelayBetweenSequentialPlaybooks = 0
		/// In seconds
		static let maxDelayBetweenSequentialPlaybooks = 0
		static let secondsPerDay = 86_400.0
	}

	private let client: Client
	private let store: Store
	private let coronaTestService: CoronaTestService
	private let fakeRequestService: FakeRequestService

	private var isAllowedToPerformBackgroundFakeRequests: Bool {
		return coronaTestService.pcrTestPublisher.value != nil || coronaTestService.antigenTestPublisher.value != nil
	}

	/// Triggers one or more fake requests over a time interval of multiple seconds.
	/// - Parameters:
	///   - completion: called after all requests were triggered. Currently, only required when running in background mode to avoid terminating before the requests were made.
	private func sendFakeRequest(_ completion: (() -> Void)? = nil) {
		let group = DispatchGroup()

		for i in 0..<Int.random(in: Constants.minNumberOfSequentialPlaybooks...Constants.maxNumberOfSequentialPlaybooks) {
			let delay = Int.random(in: Constants.minDelayBetweenSequentialPlaybooks...Constants.maxDelayBetweenSequentialPlaybooks)
			group.enter()
			DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(i * delay)) {
				self.fakeRequestService.fakeRequest()
				group.leave()
			}
		}

		// Wait for all fake request to finish and call completion handler.
		group.notify(queue: .global()) {
			completion?()
		}
	}

}
