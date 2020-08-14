//
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
//

import UIKit
import Combine

class BackgroundAppRefreshViewModel {

	enum CombinedBackgroundAppRefreshStatus {
		case on
		case off
		case offInPowerSaving
	}
	
	// MARK: - Init

	init(onOpenSettings: @escaping () -> Void, onOpenAppSettings: @escaping () -> Void) {
		self.onOpenSettings = onOpenSettings
		self.onOpenAppSettings = onOpenAppSettings
		backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
		lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
		observeBackgroundAppRefresh()
		observeLowPowerMode()
		calculateCombinedBackgroundStatus()
	}
	
	// MARK: - Internal

	let title = "Hintergrundaktualisierung"
	let subTitle = "Corona-Warn-App im Hintergrund ausführen"
	let description = """
	Bei eingeschalteter Hintergrundaktualisierung ermittelt die Corona-Warn-App Ihren Risikostatus automatisch.
	Bei ausgeschalteter Hintergrundaktualisierung müssen Sie die App täglich aufrufen, um Ihren Risikostatus zu aktualisieren.
	Es fallen hierbei keine zusätzliche Kosten für die Datenübertragung im Mobilfunknetz an.
	"""
	
	let settingsHeader = "Einstellung"
	let backgroundAppRefreshTitle = "Hintergrundaktivität"
	let infoBoxTitle = "Hintergrundaktualisierung einschalten"
	let infoBoxDescriptionOff = "Die Hintergrundaktualisierung müssen Sie sowohl in den allgemeinen Einstellungen Ihres iPhones als auch in den Einstellungen der Corona-Warn-App einschalten."
	let infoBoxDescriptionLowPowerMode = "Beachten Sie bitte, dass für das Einschalten der Hintergrundaktualisierung der Stromsparmodus ausgeschaltet sein muss."
	let infoBoxTitleImage = UIImage(named: "Icons_iOS_Hintergrundaktualisierung_Aus")
	@Published var infoBoxText: String = ""
	@Published var backgroundAppRefreshStatusText: String = ""
	@Published var image: UIImage?
	@Published var showInfoBox: Bool = false
	@Published var infoBoxViewModel: InfoBoxViewModel?

	// MARK: - Private
	
	private let onOpenSettings: () -> Void
	private let onOpenAppSettings: () -> Void
    private var subscriptions = Set<AnyCancellable>()

	private var backgroundRefreshStatus: UIBackgroundRefreshStatus {
		didSet {
			calculateCombinedBackgroundStatus()
		}
	}

	private var lowPowerModeEnabled: Bool {
		didSet {
			calculateCombinedBackgroundStatus()
		}
	}

	private var combinedBackgroundAppRefreshStatus: CombinedBackgroundAppRefreshStatus = .off {
		didSet {
			switch combinedBackgroundAppRefreshStatus {
			case .on:
				backgroundAppRefreshStatusText = "An"
				image = UIImage(named: "Illu_Hintergrundaktualisierung_An")
				infoBoxText = ""
				infoBoxViewModel = nil
			case .off:
				showInfoBox = true
				backgroundAppRefreshStatusText = "Aus"
				image = UIImage(named: "Illu_Hintergrundaktualisierung_Aus")
				infoBoxText = "TOLL NUR AUS"
				infoBoxViewModel = .init(instructions: infoBoxInstructionsForOff, titleText: infoBoxTitle, descriptionText: infoBoxDescriptionOff)
			case .offInPowerSaving:
				showInfoBox = true
				backgroundAppRefreshStatusText = "Aus"
				image = UIImage(named: "Illu_Hintergrundaktualisierung_Aus")
				infoBoxText = "DOOF STROM AUCH WEG"
				infoBoxViewModel = .init(
					instructions: infoBoxInstructionsForOff + infoBoxInstructionLowPowerMode,
					titleText: infoBoxTitle,
					descriptionText: infoBoxDescriptionOff + "\n\n" + infoBoxDescriptionLowPowerMode
				)
			}
		}
	}
	
	private var infoBoxInstructionsForOff: [InfoBoxViewModel.Instruction] {
		[
			.init(title: "Hintergrundakualisierung allgemein einschalten", steps: [
				.init(icon: UIImage(named: "Icons_iOS_Settings"), text: "Öffnen Sie Einstellungen."),
				.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: "Öffnen Sie Allgemein."),
				.init(icon: nil, text: "Öffnen Sie Hintergrundaktualisierung."),
				.init(icon: nil, text: "Wählen Sie entweder WLAN oder WLAN & Mobile Daten.")
			]),
			.init(title: "Hintergrundaktualisierung für die Corona-Warn-App einschalten", steps: [
				.init(icon: UIImage(named: "Icons_iOS_Settings"), text: "Öffnen Sie Einstellungen."),
				.init(icon: UIImage(named: "Icons_CWAAppIcon"), text: "Öffnen Sie die Corona-Warn-App Einstellung."),
				.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: "Schalten Sie Hintergrundaktualisierung ein.")
			])
		]
	}
	
	private var infoBoxInstructionLowPowerMode: [InfoBoxViewModel.Instruction] {
		[
			.init(title: "Stromsparmodus ausschalten", steps: [
				.init(icon: UIImage(named: "Icons_iOS_Settings"), text: "Öffnen Sie Einstellungen."),
				.init(icon: UIImage(named: "Icons_Energie"), text: "Öffnen Sie Batterie."),
				.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: "Schalten Sie den Stromsparmodus aus.")
			])
		]
	}

	private func observeBackgroundAppRefresh() {
		NotificationCenter.default.publisher(for: UIApplication.backgroundRefreshStatusDidChangeNotification).sink { [weak self] _ in
			self?.backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
		}.store(in: &subscriptions)
	}
	
	private func observeLowPowerMode() {
		NotificationCenter.default.publisher(for: Notification.Name.NSProcessInfoPowerStateDidChange).sink { [weak self] _ in
			self?.lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
		}.store(in: &subscriptions)
	}

	private func calculateCombinedBackgroundStatus() {
		if backgroundRefreshStatus == .available {
			combinedBackgroundAppRefreshStatus = .on
		} else {
			combinedBackgroundAppRefreshStatus = lowPowerModeEnabled ? .offInPowerSaving : .off
		}
	}

}
