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

class DeltaOnboardingCoordinator: RequiresAppDependencies {

	// MARK: - Attributes

	private weak var rootViewController: UIViewController?
	private let onboardings: [DeltaOnboarding]

	var finished: (() -> Void)?

	// MARK: - Initializers

	init(rootViewController: UIViewController, onboardings: [DeltaOnboarding]) {
		self.rootViewController = rootViewController
		self.onboardings = onboardings
	}

	// MARK: - Internal API

	func startOnboarding() {
		showNextOnboardingViewController()
	}

	// MARK: - Private API

	private func showNextOnboardingViewController() {
		guard let onboarding = nextOnboarding() else {
			finished?()
			return
		}
		
		appConfigurationProvider.appConfiguration { applicationConfiguration in
			
			let supportedCountries = applicationConfiguration?.supportedCountries.compactMap({ Country(countryCode: $0) }) ?? []
						
			let onboardingViewController = onboarding.makeViewController(supportedCountries: supportedCountries)

			onboardingViewController.finished = { [weak self] in
				self?.rootViewController?.dismiss(animated: true)
				onboarding.finish()
				self?.showNextOnboardingViewController()
			}

			let navigationController = DeltaOnboardingNavigationController(rootViewController: onboardingViewController)
			navigationController.finished = { [weak self] in
				self?.rootViewController?.dismiss(animated: true)
				onboarding.finish()
				self?.showNextOnboardingViewController()
			}
			
			self.rootViewController?.present(navigationController, animated: true)
		}

		
	}

	private func nextOnboarding() -> DeltaOnboarding? {
		return onboardings.first(where: { !$0.isFinished })
	}
	
	
}
