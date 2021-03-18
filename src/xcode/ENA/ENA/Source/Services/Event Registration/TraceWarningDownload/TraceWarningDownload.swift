////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol TraceWarningPackageDownloading {
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)? { get set }
	
	func startTraceWarningPackageDownload(completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void)
}

enum TraceWarningDownloadError: Error {
	case uncompletePackages
	case noDiskSpace
	case unableToWriteTraceWarnings
	case downloadIsRunning
	case errorAtDiscovery(TraceWarningError)
	case errorAtDownload(TraceWarningError)
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
		eventStore: EventStoringProviding,
		appConfigurationProvider: AppConfigurationProviding,
		countries: [Country.ID] = ["DE"]
	) {
		self.client = client
		self.store = store
		self.eventStore = eventStore
		self.appConfigurationProvider = appConfigurationProvider
		self.countries = countries
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningPackageDownloading
	
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)?
	
	func startTraceWarningPackageDownload(
		completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void
	) {
		Log.info("TraceWarningPackageDownload: Start was triggered.", log: .checkin)
		
		// Cancel Download if a download is still in progress
		guard status == .idle else {
			Log.info("TraceWarningPackageDownload: Aborted due to already running download.", log: .checkin)
			completion(.failure(.downloadIsRunning))
			return
		}
		
		// 1. Check for check-ins
		guard !eventStore.checkinsPublisher.value.isEmpty else {
			// If the database is empty, remove all traceWarningPackageMetadatas
			let packagesToDelete = eventStore.traceWarningPackageMetadatasPublisher.value
			packagesToDelete.forEach { traceWarningPackage in
				eventStore.deleteTraceWarningPackageMetadata(id: traceWarningPackage.id)
			}
			Log.info("TraceWarningPackageDownload: Aborted due to checkin database is empty.", log: .checkin)
			completion(.success(()))
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
	private let eventStore: EventStoringProviding
	private let countries: [Country.ID]
	private let appConfigurationProvider: AppConfigurationProviding
	
	private var subscriptions: Set<AnyCancellable> = []
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
		
		// Download packages for each country
		countries.forEach { [weak self] country in
			Log.info("TraceWarningPackageDownload: Start processsing package download for country: \(country).", log: .checkin)
			
			// Check if we did not discover in the same hour before.
			if shouldStartPackageDownload(for: country) {
				countriesDG.enter()
				
				// Go now for the real download
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
		// 2. Update the app config.
		appConfigurationProvider.appConfiguration().sink { [weak self] config in
			
			// 3. Clean up Revoked Packages.
			let packages = config.keyDownloadParameters.revokedTraceWarningPackages
			
			packages.forEach { traceWarningPackage in
				let eTag = traceWarningPackage.etag
				let matchingPackages = self?.eventStore.traceWarningPackageMetadatasPublisher.value.filter {
					return $0.eTag == eTag
				}
				matchingPackages?.forEach { traceWarningPackages in
					self?.eventStore.deleteTraceWarningPackageMetadata(id: traceWarningPackages.id)
				}
			}
			
			// 4. Determine availablePackagesOnCDN (http discovery)
			self?.client.traceWarningPackageDiscovery(country: country, completion: { result in
				
				switch result {
				case let .success(traceWarningDiscovery):
					Log.info("TraceWarningPackageDownload: Discover trace warning packages successfull.")
					
					// Check if they are empty. If so, nothing more todo.
					guard !traceWarningDiscovery.availablePackagesOnCDN.isEmpty else {
						Log.info("TraceWarningPackageDownload: Discovered trace warning packages are empty.")
						completion(.success(()))
						return
					}
				
				case let .failure(error):
					Log.error("TraceWarningPackageDownload: Error at discovery trace warning packages.", log: .checkin, error: error)
					completion(.failure(.errorAtDiscovery(error)))
				}
			})
		}.store(in: &subscriptions)

		
	}
	
}
