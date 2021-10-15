////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import AVFoundation

class OnBehalfTraceLocationSelectionViewModel {
	
	// MARK: - Init
	
	init(
		traceLocations: [TraceLocation]
	) {
		self.traceLocationCellModels = traceLocations
			.map { TraceLocationSelectionCellModel(traceLocation: $0) }
	}
		
	// MARK: - Internal
	
	enum Section: Int, CaseIterable {
		case description
		case qrCodeScan
		case traceLocations
	}
	
	let title = AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.title

	let traceLocationCellModels: [TraceLocationSelectionCellModel]

	@OpenCombine.Published private(set) var continueEnabled: Bool = false

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmptyStateVisible: Bool {
		traceLocationCellModels.isEmpty
	}
	
	var selectedTraceLocation: TraceLocation?
	
	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return 1
		case .qrCodeScan:
			return 1
		case .traceLocations:
			return traceLocationCellModels.count
		case .none:
			Log.error("ExposureSubmissionCheckinsViewModel: numberOfRows asked for unknown section", log: .ui, error: nil)
			return 0
		}
	}
	
	func toggleSelection(at tappedIndex: Int) {
		for (index, traceLocationCellModel) in traceLocationCellModels.enumerated() {
			if index == tappedIndex {
				traceLocationCellModel.selected.toggle()

				selectedTraceLocation = traceLocationCellModel.selected ? traceLocationCellModel.traceLocation : nil
			} else {
				traceLocationCellModel.selected = false
			}
		}

		checkContinuePossible()
	}
	
	// MARK: - Private
	
	private func checkContinuePossible() {
		continueEnabled = selectedTraceLocation != nil
	}
	
}
