////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol TraceWarningPackageDownloading {
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)? { get set }
	
	/// Starts to download the traceWarningPackages from CDN by following several checks and steps. Does return nothing. Stores the successfull downloaded and verified packages in the database, also the matches from the downloaded ones to the local check-ins. Return for failure a TraceWarningError and for success a TraceWarningSuccess. The success shall not be handled but it passed for testing purposes.
	func startTraceWarningPackageDownload(
		with appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	)
}

enum TraceWarningDownloadStatus {
	case idle
	case checkingForNewPackages
	case downloading
}

class TraceWarningPackageDownload: TraceWarningPackageDownloading {
	
	// MARK: - Init
	
	init(
		client: Client,
		store: Store,
		eventStore: EventStoringProviding,
		countries: [Country.ID] = ["DE"],
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.client = client
		self.store = store
		self.eventStore = eventStore
		self.countries = countries
		self.signatureVerifier = signatureVerifier
		
		self.matcher = TraceWarningMatcher(eventStore: eventStore)
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningPackageDownloading
	
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)?
	
	func startTraceWarningPackageDownload(
		with appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		Log.info("TraceWarningPackageDownload: Start was triggered.", log: .checkin)
		
		// Refuse another download if a download is still running
		guard status == .idle else {
			Log.info("TraceWarningPackageDownload: Aborted due to already running download.", log: .checkin)
			completion(.failure(.downloadIsRunning))
			return
		}
		
		// 1. Check for check-ins
		guard !eventStore.checkinsPublisher.value.isEmpty else {
			// If the database is empty, remove all traceWarningPackageMetadatas
			let packagesToDelete = eventStore.traceWarningPackageMetadatasPublisher.value
			removePackagesFromTraceWarningMetadataPackagesTable(packagesToDelete)
			Log.info("TraceWarningPackageDownload: Aborted due to checkin database is empty.", log: .checkin)
			completion(.success(.noCheckins))
			return
		}

		status = .checkingForNewPackages
		
		checkForDownloadTraceWarningPackages(with: appConfiguration, countries: countries, completion: { [weak self] result in
			self?.status = .idle
			
			switch result {
			case let .success(success):
				Log.info("TraceWarningPackageDownload: Completed processing packages!", log: .checkin)
				completion(.success(success))
			case let .failure(error):
				Log.info("TraceWarningPackageDownload: Failed processing packages with error: \(error)")
				completion(.failure(error))
			}
		})
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	/// Determines the earliest relevant package id == the min of the checkin database table. Not private for testing purposes.
	var earliestRelevantPackageId: Int? {
		let minCheckin = eventStore.checkinsPublisher.value.min(by: { $0.checkinStartDate < $1.checkinStartDate })
		return minCheckin?.checkinStartDate.unixTimestampInHours
	}
	
	/// Checks if we already downloaded packages last hour. Return true if last download was not successfull or we did not download in the last hour. Not private for testing purposes.
	func shouldStartPackageDownload(
		for country: Country.ID
	) -> Bool {
		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date())?.unixTimestampInHours else {
			Log.error("TraceWarningPackageDownload: Could not create last hour date.", log: .checkin)
			fatalError("TraceWarningPackageDownload: Could not create last hour date.")
		}
		
		let lastHourInDatabase = eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == lastHourDate })
		let shouldStart = !lastHourInDatabase || !store.wasRecentTraceWarningDownloadSuccessful
		Log.info("TraceWarningPackageDownload: ShouldStartPackageDownload: \(shouldStart)", log: .checkin)
		return shouldStart
	}
	
	/// Filters all by the app config revoked TraceWarningMetadataPackages and removes them from the database table TraceWarningMetadataPackages. Identified by their eTag. Not private for testing purposes.
	func removeRevokedTraceWarningMetadataPackages(
		_ revokedPackages: [SAP_Internal_V2_TraceWarningPackageMetadata]
	) {
		let packagesToRemove = eventStore.traceWarningPackageMetadatasPublisher.value.filter({ databasePackage in
			revokedPackages.contains(where: { appConfigPackage in
				databasePackage.eTag == appConfigPackage.etag
			})
		})
		
		removePackagesFromTraceWarningMetadataPackagesTable(packagesToRemove)
	}
	
	/// Filters all outdated TraceWarningMetadataPackages and removes them from the database table TraceWarningMetadataPackages. Not private for testing purposes.
	func cleanUpOutdatedMetadata(
		oldest oldestPackage: Int,
		earliest earliestRelevantPackage: Int
	) {
		// Take the max of the oldest and earliestRelevantPackage and remove all metadatas that are older then this max.
		let maxId = max(oldestPackage, earliestRelevantPackage)
		let packagesToDelete = eventStore.traceWarningPackageMetadatasPublisher.value.filter({ return $0.id < maxId })
		Log.info("TraceWarningPackageDownload: Clean up packages: \(packagesToDelete).")
		removePackagesFromTraceWarningMetadataPackagesTable(packagesToDelete)
	}
	
	/// Filters out the packages to be downloaded by subtracting the actual packages from the available packages. Not private for testing purposes.
	func determinePackagesToDownload(
		availables availablePackagesOnCDN: [Int],
		earliest earliestRelevantPackage: Int
	) -> Set<Int> {
		// Get all packages that are earlier then the earliestRelevantPackage
		let earlierPackages = Set(availablePackagesOnCDN.filter { return $0 >= earliestRelevantPackage })
		// Now filter out all entries that are not in our metadata database
		let metadataIds = Set(eventStore.traceWarningPackageMetadatasPublisher.value.map { $0.id })
		return earlierPackages.subtracting(metadataIds)
	}
	
	// MARK: - Private
	
	private let client: Client
	private let store: Store
	private let eventStore: EventStoringProviding
	private let countries: [Country.ID]
	private let matcher: TraceWarningMatching
	private let signatureVerifier: SignatureVerification
	
	private var subscriptions: Set<AnyCancellable> = []
	private var status: TraceWarningDownloadStatus = .idle {
		didSet {
			statusDidChange?(status)
		}
	}
	
	private func checkForDownloadTraceWarningPackages(
		with appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		countries: [Country.ID],
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		let countriesDG = DispatchGroup()
		var errors = [TraceWarningError]()
		var successes = [TraceWarningSuccess]()
		
		// Download packages for each country
		countries.forEach { country in
			Log.info("TraceWarningPackageDownload: Start processsing package download for country: \(country).", log: .checkin)
			
			// Check if we did not discover in the same hour before.
			if shouldStartPackageDownload(for: country) {
				countriesDG.enter()
				
				// Go now for the real download
				downloadTraceWarningPackages(with: appConfig, for: country, completion: { result in
					switch result {
					case let .success(success):
						Log.info("TraceWarningPackageDownload: Succeded downloading packages for country id: \(country).", log: .checkin)
						successes.append(success)
					case let .failure(error):
						Log.info("TraceWarningPackageDownload: Failed downloading packages for country id: \(country).", log: .checkin)
						errors.append(error)
					}
					
					countriesDG.leave()
				})
			}
		}
		
		countriesDG.notify(queue: .main) { [weak self] in
			if let error = errors.first {
				Log.error("TraceWarningPackageDownload: Failed downloading packages for all countries with errors: \(errors).", log: .checkin)
				self?.store.wasRecentTraceWarningDownloadSuccessful = false
				completion(.failure(error))
			} else {
				Log.info("TraceWarningPackageDownload: Completed downloading packages for all countries.", log: .checkin)
				self?.store.wasRecentTraceWarningDownloadSuccessful = true
				// pass the success case only for testing through
				if successes.contains(.emptyAvailablePackages) {
					completion(.success(.emptyAvailablePackages))
				} else if successes.contains(.emptySinglePackage) {
					completion(.success(.emptySinglePackage))
				} else {
					completion(.success(.success))
				}
			}
		}
	}
		
	private func downloadTraceWarningPackages(
		with appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		for country: Country.ID,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		// 2. Instead of updating the app config again, we got it injected.
		// 3. Clean up revoked Packages.
		let revokedPackages = appConfig.keyDownloadParameters.revokedTraceWarningPackages
		removeRevokedTraceWarningMetadataPackages(revokedPackages)
		
		self.status = .downloading
		
		// 4. Determine availablePackagesOnCDN (http discovery)
		client.traceWarningPackageDiscovery(country: country, completion: { [weak self] result in
			
			switch result {
			case let .success(traceWarningDiscovery):
				self?.processDiscoverdPackages(traceWarningDiscovery, country: country, completion: completion)
				
			case let .failure(error):
				Log.error("TraceWarningPackageDownload: Error at discovery trace warning packages.", log: .checkin, error: error)
				completion(.failure(error))
			}
		})
	}
	
	private func processDiscoverdPackages(
		_ discoveredTraceWarnings: TraceWarningDiscovery,
		country: Country.ID,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		
		Log.info("TraceWarningPackageDownload: Discover trace warning packages successfully.")
				
		let availablePackagesOnCDN = discoveredTraceWarnings.availablePackagesOnCDN
		
		// Check if they are empty. If so, nothing more todo.
		guard !availablePackagesOnCDN.isEmpty else {
			Log.info("TraceWarningPackageDownload: Discovered trace warning packages are empty.")
			completion(.success(.emptyAvailablePackages))
			return
		}
		Log.info("TraceWarningPackageDownload: AvailablePackagesOnCDN are not empty. Proceed with determination of packages to download...")
		
		// 5. Determine earliestRelevantPackage.
		// Take the database entry with the oldest checkinStartDate and convert it to unix timestamp in hours.
		// Normally, this is an edge case because we have a check at the beginning for an empty checkin database table. So the database should be cleared after our check. Possible, but rarely.
		guard let earliestRelevantPackage = earliestRelevantPackageId else {
			Log.error("TraceWarningPackageDownload: Could not determine earliestRelevantPackage. Abort Download.", log: .checkin)
			completion(.failure(.noEarliestRelevantPackage))
			return
		}

		// 6. Clean up the trace warning package metadatas.
		cleanUpOutdatedMetadata(oldest: discoveredTraceWarnings.oldest, earliest: earliestRelevantPackage)
				
		// 7. Determine packagesToDownload
		let packagesToDownload = determinePackagesToDownload(availables: availablePackagesOnCDN, earliest: earliestRelevantPackage)

		Log.info("TraceWarningPackageDownload: Determined packages to download: \(packagesToDownload). Proceed with downloading the single packages...")
		self.downloadDeterminedPackages(packageIds: packagesToDownload, country: country, completion: completion)
	}
	
	private func downloadDeterminedPackages(
		packageIds: Set<Int>,
		country: Country.ID,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		
		let singlePackageDispatchGroup = DispatchGroup()
		var packagesErrors = [TraceWarningError]()
		var packagesSuccesses = [TraceWarningSuccess]()
		
		// 8. download now for each packageId the package itself. There can be also empty packages, indicated by a property in the downloaded package.
		packageIds.forEach { packageId in
			singlePackageDispatchGroup.enter()
			
			downloadSinglePackage(packageId: packageId, country: country, completion: { result in
				switch result {

				case let .success(success):
					Log.info("TraceWarningPackageDownload: Download of single packageId: \(packageId) succesfully completed.")
					packagesSuccesses.append(success)
				case let .failure(error):
					Log.info("TraceWarningPackageDownload: Download of single packageId: \(packageId) failed with error: \(error).")
					packagesErrors.append(error)
				}
				
				singlePackageDispatchGroup.leave()
			})
		}
		
		singlePackageDispatchGroup.notify(queue: .global(qos: .utility), execute: {
			if let error = packagesErrors.first {
				completion(.failure(error))
			} else {
				if packagesSuccesses.contains(.emptySinglePackage) {
					completion(.success(.emptySinglePackage))
				} else {
					completion(.success(.success))
				}
			}
		})
	}
	
	private func downloadSinglePackage(
		packageId: Int,
		country: Country.ID,
		completion: @escaping (Result<TraceWarningSuccess, TraceWarningError>) -> Void
	) {
		Log.info("TraceWarningPackageDownload: Try to download single package with id: \(packageId) ...")
		client.traceWarningPackageDownload(country: country, packageId: packageId, completion: { [weak self] result in
			
			guard let self = self else {
				Log.error("TraceWarningPackageDownload: Could not create strong self. Abord verification and matching for packageId: \(packageId)", log: .checkin)
				completion(.failure(.generalError))
				return
			}
			
			switch result {
			case let .success(packageDownloadResponse):
				Log.info("TraceWarningPackageDownload: Successfully downloaded single packageId: \(packageId). Proceed with verification and matching...", log: .checkin)
				
				// 9. Verfify signature for every not-empty package.
				guard !packageDownloadResponse.isEmpty,
					  let sapDownloadedPackage = packageDownloadResponse.package else {
					Log.info("TraceWarningPackageDownload: PackageId: \(packageId) is empty and was discarded.")
					completion(.success(.emptySinglePackage))
					return
				}
				
				guard let eTag = packageDownloadResponse.etag else {
					Log.error("TraceWarningPackageDownload: ETag of packageId: \(packageId) missing. Discard package.")
					completion(.failure(.identicationError))
					return
				}
				
				guard self.signatureVerifier.verify(sapDownloadedPackage) else {
					Log.warning("TraceWarningPackageDownload: Verification of packageId: \(packageId) failed. Discard package but complete download as success.")
					completion(.failure(.verificationError))
					return
				}
				
				Log.info("TraceWarningPackageDownload: Verification of packageId: \(packageId) successful. Proceed with matching and storing the package.")
				
				// 10.+ 11. Match the verified package and store them.
				self.matcher.matchAndStore(package: sapDownloadedPackage)
				
				Log.info("TraceWarningPackageDownload: Matching of packageId: \(packageId) done. Proceed with storing the package.")
				
				// 12. Store downloaded and verified
				let traceWarningPackageMetadata = TraceWarningPackageMetadata(
					id: packageId,
					region: country,
					eTag: eTag
				)
				self.eventStore.createTraceWarningPackageMetadata(traceWarningPackageMetadata)
				
				Log.info("TraceWarningPackageDownload: Storing of packageId: \(packageId) done.")
				completion(.success(.success))
				
				
			case let .failure(error):
				Log.error("TraceWarningPackageDownload: Error at download single package with id: \(packageId).", log: .checkin, error: error)
				completion(.failure(error))
			}
		})
	}
	
	// MARK: - Private helpers
	
	/// Removes packages from database table TraceWarningMetadataPackages. Identified by their id.
	private func removePackagesFromTraceWarningMetadataPackagesTable(
		_ packages: [TraceWarningPackageMetadata]
	) {
		packages.forEach { package in
			eventStore.deleteTraceWarningPackageMetadata(id: package.id)
		}
	}
}
