//
// 🦠 Corona-Warn-App
//

import ExposureNotification

protocol CountryKeypackageDownloading {
	typealias Completion = (Result<Void, ExposureDetection.DidEndPrematurelyReason>) -> Void

	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion)
}

class CountryKeypackageDownloader: CountryKeypackageDownloading {

	private weak var delegate: ExposureDetectionDelegate?

	init(delegate: ExposureDetectionDelegate?) {
		self.delegate = delegate
	}

	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion) {

		Log.info("CountryKeypackageDownloader: Start determine available data.", log: .riskDetection)

		delegate?.exposureDetection(country: country, determineAvailableData: { [weak self] daysAndHours, country in
			guard let self = self else { return }
			Log.info("CountryKeypackageDownloader: Completed determine available data.", log: .riskDetection)

			self.downloadDeltaUsingAvailableRemoteData(daysAndHours, country: country, completion: completion)
		})
	}

	private func downloadDeltaUsingAvailableRemoteData(_ daysAndHours: DaysAndHours?, country: Country.ID, completion: @escaping Completion) {

		Log.info("CountryKeypackageDownloader: Determine delta data.", log: .riskDetection)

		guard let daysAndHours = daysAndHours else {
			completion(.failure(.noDaysAndHours))
			return
		}

		guard let deltaDaysAndHours = delegate?.exposureDetection(country: country, downloadDeltaFor: daysAndHours) else {
			completion(.failure(.noDaysAndHours))
			return
		}

		Log.info("CountryKeypackageDownloader: Completed determine delta data.", log: .riskDetection)

		Log.info("CountryKeypackageDownloader: Start downloading delta data.", log: .riskDetection)
		delegate?.exposureDetection(country: country, downloadAndStore: deltaDaysAndHours) { error in
			if let error = error {
				Log.error("CountryKeypackageDownloader: Error while downloading delta data.", log: .riskDetection, error: error)
				completion(.failure(error))
			} else {
				Log.info("CountryKeypackageDownloader: Completed downloading delta data.", log: .riskDetection)
				completion(.success(()))
			}
		}
	}

}
