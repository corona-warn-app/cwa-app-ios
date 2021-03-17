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
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningPackageDownloading
	
	var statusDidChange: ((TraceWarningDownloadStatus) -> Void)?
	
	func startTraceWarningPackageDownload(completion: @escaping (Result<Void, TraceWarningDownloadError>) -> Void) {
		completion(.success(()))
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
}
