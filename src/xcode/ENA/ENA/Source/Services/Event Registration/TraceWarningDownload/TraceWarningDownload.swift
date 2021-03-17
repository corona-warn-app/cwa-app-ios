////
// 🦠 Corona-Warn-App
//

import Foundation

protocol TraceWarningPackageDownloading {
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)? { get set }
	
	func startTraceWarningPackageDownload(completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void)
}

enum TraceWarningDownloadError: Error {
	case uncompletePackages
	case noDiskSpace
	case unableToWriteTraceWarnings
	case downloadIsRunning
}

enum TraceWarningDownloadStatus {
	case idle
	case checkingForNewPackages
	case downloading
}

class TraceWarningDownload: TraceWarningPackageDownloading {
	
	// MARK: - Init
	
	init(
		client: Client,
		store: Store,
		countries: [Country.ID] = ["DE"]
	) {
		self.client = client
		self.store = store
		self.countries = countries
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningPackageDownloading
	
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)?
	
	func startTraceWarningPackageDownload(
		completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void
	) {
		Log.info("TraceWarningPackageDownload: Start was triggered.", log: .checkin)
		
		guard status == .idle else {
			Log.info("TraceWarningPackageDownload: Aborted due to already running download.", log: .checkin)
			completion(.failure(.downloadIsRunning))
			return
		}
		
		status = .checkingForNewPackages
		
		checkForDownloadTraceWarningPackages(countries: countries, completion: { [weak self] result in
			self?.status = .idle
			
			switch result {
			
			case .success:
				Log.info("TraceWarningPackageDownload: Completed processing packages!", log: .checkin)
				completion(.success(()))
			case let .failure(error):
				Log.info("TraceWarningPackageDownload: Failed processing packages with error: \(error)")
				completion(.failure(error))
			}
		})
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let client: Client
	private let store: Store
	private let countries: [Country.ID]
	
	private var status: TraceWarningDownloadStatus = .idle {
		didSet {
			statusDidChange?(status)
		}
	}
	
	private func checkForDownloadTraceWarningPackages(
		countries: [Country.ID],
		completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void
	) {
		let countriesDG = DispatchGroup()
		var errors = [TraceWarningDownloadError]()
		
		countries.forEach { [weak self] country in
			Log.info("TraceWarningPackageDownload: Start processsing package download for country: \(country).", log: .checkin)
			
			if shouldStartPackageDownload(for: country) {
				countriesDG.enter()
				
				self?.downloadTraceWarningPackages(for: country, completion: { result in
					switch result {
					case .success:
						Log.info("TraceWarningPackageDownload: Succeded downloading packages for country id: \(country).", log: .checkin)
					case .failure(let error):
						Log.info("TraceWarningPackageDownload: Failed downloading packages for country id: \(country).", log: .checkin)
						errors.append(error)
					}

					countriesDG.leave()
				})
			}
		}
		
		countriesDG.notify(queue: .main) {
			if let error = errors.first {
				Log.error("TraceWarningPackageDownload: Failed downloading packages with errors: \(errors).", log: .checkin)
				self.store.wasRecentTraceWarningDownloadSuccessful = false
				completion(.failure(error))
			} else {
				Log.info("TraceWarningPackageDownload: Completed downloading packages to cache.", log: .checkin)
				self.store.wasRecentTraceWarningDownloadSuccessful = true
				completion(.success(()))
			}
		}
		
	}
	
	private func shouldStartPackageDownload(
		for country: Country.ID
	) -> Bool {
		// Did we check that already this hour?
		let returnValue = true
		Log.debug("TraceWarningPackageDownload: ShouldStartPackageDownload: \(returnValue)", log: .checkin)
		return returnValue
	}
	
	private func downloadTraceWarningPackages(
		for country: Country.ID,
		completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void
	) {
		
	}
	
}
