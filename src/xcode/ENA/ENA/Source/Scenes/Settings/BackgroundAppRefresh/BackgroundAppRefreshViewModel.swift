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

protocol LowPowerModeStatusProviding {
	var isLowPowerModeEnabled: Bool { get }
}

extension ProcessInfo: LowPowerModeStatusProviding { }

protocol BackgroundRefreshStatusProviding {
	var backgroundRefreshStatus: UIBackgroundRefreshStatus { get }
}

extension UIApplication: BackgroundRefreshStatusProviding { }

class BackgroundAppRefreshViewModel {

	enum CombinedBackgroundAppRefreshStatus {
		case on
		case off
		case offInPowerSaving
	}
	
	// MARK: - Init

	init(
		backgroundRefreshStatusProvider: BackgroundRefreshStatusProviding = UIApplication.shared,
		lowPowerModeStatusProvider: LowPowerModeStatusProviding = ProcessInfo.processInfo,
		onOpenSettings: @escaping () -> Void,
		onShare: @escaping () -> Void
	) {
		self.backgroundRefreshStatusProvider = backgroundRefreshStatusProvider
		self.lowPowerModeStatusProvider = lowPowerModeStatusProvider
		self.onOpenSettings = onOpenSettings
		self.onShare = onShare

		backgroundRefreshStatus = backgroundRefreshStatusProvider.backgroundRefreshStatus
		lowPowerModeEnabled = lowPowerModeStatusProvider.isLowPowerModeEnabled
		observeBackgroundAppRefresh()
		observeLowPowerMode()
		calculateCombinedBackgroundStatus()
	}
	
	// MARK: - Internal

	let title = AppStrings.BackgroundAppRefreshSettings.title
	let subTitle = AppStrings.BackgroundAppRefreshSettings.subtitle
	let description = AppStrings.BackgroundAppRefreshSettings.description
	
	let settingsHeaderTitle = AppStrings.BackgroundAppRefreshSettings.Status.header.uppercased()
	let backgroundAppRefreshTitle = AppStrings.BackgroundAppRefreshSettings.Status.title

	@Published var backgroundAppRefreshStatusText: String = ""
	@Published var backgroundAppRefreshStatusAccessibilityLabel: String = ""
	@Published var backgroundAppRefreshStatusImageAccessibilityLabel: String = ""
	@Published var image: UIImage?
	@Published var infoBoxViewModel: InfoBoxViewModel?


	// MARK: - Private

	private let backgroundRefreshStatusProvider: BackgroundRefreshStatusProviding
	private let lowPowerModeStatusProvider: LowPowerModeStatusProviding
	private let onOpenSettings: () -> Void
	private let onShare: () -> Void

    private var subscriptions = Set<AnyCancellable>()

	private let infoBoxTitle = AppStrings.BackgroundAppRefreshSettings.InfoBox.title
	private let infoBoxDescriptionOff = AppStrings.BackgroundAppRefreshSettings.InfoBox.description
	private let infoBoxDescriptionLowPowerMode = AppStrings.BackgroundAppRefreshSettings.InfoBox.lowPowerModeDescription
	private let infoBoxTitleImage = UIImage(named: "Icons_iOS_Hintergrundaktualisierung_Aus")
	private let buttonTextShare = AppStrings.BackgroundAppRefreshSettings.shareButtonTitle
	private let buttonTextSettings = AppStrings.BackgroundAppRefreshSettings.openSettingsButtonTitle

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
				backgroundAppRefreshStatusText = AppStrings.BackgroundAppRefreshSettings.Status.on
				backgroundAppRefreshStatusImageAccessibilityLabel = AppStrings.BackgroundAppRefreshSettings.onImageDescription
				image = UIImage(named: "Illu_Hintergrundaktualisierung_An")
				infoBoxViewModel = nil
			case .off:
				backgroundAppRefreshStatusText = AppStrings.BackgroundAppRefreshSettings.Status.off
				backgroundAppRefreshStatusImageAccessibilityLabel = AppStrings.BackgroundAppRefreshSettings.offImageDescription
				image = UIImage(named: "Illu_Hintergrundaktualisierung_Aus")
				infoBoxViewModel = .init(
					instructions: infoBoxInstructionsForOff,
					titleText: infoBoxTitle,
					descriptionText: infoBoxDescriptionOff,
					settingsText: buttonTextSettings,
					shareText: buttonTextShare,
					settingsAction: onOpenSettings,
					shareAction: onShare
				)
			case .offInPowerSaving:
				backgroundAppRefreshStatusText = AppStrings.BackgroundAppRefreshSettings.Status.off
				backgroundAppRefreshStatusImageAccessibilityLabel = AppStrings.BackgroundAppRefreshSettings.offImageDescription
				image = UIImage(named: "Illu_Hintergrundaktualisierung_Aus")
				infoBoxViewModel = .init(
					instructions: infoBoxInstructionLowPowerMode + infoBoxInstructionsForOff,
					titleText: infoBoxTitle,
					descriptionText: infoBoxDescriptionOff + "\n\n" + infoBoxDescriptionLowPowerMode,
					settingsText: buttonTextSettings,
					shareText: buttonTextShare,
					settingsAction: onOpenSettings,
					shareAction: onShare
				)
			}

			backgroundAppRefreshStatusAccessibilityLabel = backgroundAppRefreshTitle + " " + backgroundAppRefreshStatusText
		}
	}
	
	private var infoBoxInstructionsForOff: [InfoBoxViewModel.Instruction] {
		[
			.init(
				title: AppStrings.BackgroundAppRefreshSettings.InfoBox.SystemBackgroundRefreshInstruction.title,
				steps: [
					.init(icon: UIImage(named: "Icons_iOS_Settings"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.SystemBackgroundRefreshInstruction.step1),
					.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.SystemBackgroundRefreshInstruction.step2),
					.init(icon: nil, text: AppStrings.BackgroundAppRefreshSettings.InfoBox.SystemBackgroundRefreshInstruction.step3),
					.init(icon: nil, text: AppStrings.BackgroundAppRefreshSettings.InfoBox.SystemBackgroundRefreshInstruction.step4)
				]
			),
			.init(
				title: AppStrings.BackgroundAppRefreshSettings.InfoBox.AppBackgroundRefreshInstruction.title,
				steps: [
					.init(icon: UIImage(named: "Icons_iOS_Settings"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.AppBackgroundRefreshInstruction.step1),
					.init(icon: UIImage(named: "Icons_CWAAppIcon"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.AppBackgroundRefreshInstruction.step2),
					.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.AppBackgroundRefreshInstruction.step3)
				]
			)
		]
	}
	
	private var infoBoxInstructionLowPowerMode: [InfoBoxViewModel.Instruction] {
		[
			.init(
				title: AppStrings.BackgroundAppRefreshSettings.InfoBox.LowPowerModeInstruction.title,
				steps: [
					.init(icon: UIImage(named: "Icons_iOS_Settings"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.LowPowerModeInstruction.step1),
					.init(icon: UIImage(named: "Icons_Energie"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.LowPowerModeInstruction.step2),
					.init(icon: UIImage(named: "Icons_iOS_Einstellungen"), text: AppStrings.BackgroundAppRefreshSettings.InfoBox.LowPowerModeInstruction.step3)
				]
			)
		]
	}

	private func observeBackgroundAppRefresh() {
		NotificationCenter.default.publisher(for: UIApplication.backgroundRefreshStatusDidChangeNotification).sink { [weak self] _ in
			guard let self = self else { return }

			self.backgroundRefreshStatus = self.backgroundRefreshStatusProvider.backgroundRefreshStatus
		}.store(in: &subscriptions)
	}
	
	private func observeLowPowerMode() {
		NotificationCenter.default.publisher(for: Notification.Name.NSProcessInfoPowerStateDidChange).sink { [weak self] _ in
			guard let self = self else { return }

			self.lowPowerModeEnabled = self.lowPowerModeStatusProvider.isLowPowerModeEnabled
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
