//
// 🦠 Corona-Warn-App
//

extension AppDelegate {
	#if DEBUG
	func setupOnboardingForTesting() {
		if isUITesting {
			// Only disable onboarding if it was explicitly set to "NO"
			if let isOnboarded = LaunchArguments.onboarding.isOnboarded.stringValue {
				store.isOnboarded = isOnboarded != "NO"
			}

			if let onboardingVersion = LaunchArguments.onboarding.onboardingVersion.stringValue {
				store.onboardingVersion = onboardingVersion
			}

			if LaunchArguments.onboarding.resetFinishedDeltaOnboardings.boolValue {
				store.finishedDeltaOnboardings = [:]
			}

			if LaunchArguments.onboarding.setCurrentOnboardingVersion.boolValue {
				store.onboardingVersion = Bundle.main.appVersion
			}
		}
	}

	func setupDatadonationForTesting() {
		if isUITesting {
			store.isPrivacyPreservingAnalyticsConsentGiven = LaunchArguments.consent.isDatadonationConsentGiven.boolValue
		}
	}

	func setupInstallationDateForTesting() {
		if isUITesting, let installationDaysString = LaunchArguments.common.appInstallationDays.stringValue {
			let installationDays = Int(installationDaysString) ?? 0
			let date = Calendar.current.date(byAdding: .day, value: -installationDays, to: Date())
			store.appInstallationDate = date
		}
	}

	func setupAntigenTestProfileForTesting() {
		if isUITesting {
			store.antigenTestProfileInfoScreenShown = LaunchArguments.infoScreen.antigenTestProfileInfoScreenShown.boolValue
			if LaunchArguments.test.antigen.removeAntigenTestProfile.boolValue {
				store.antigenTestProfile = nil
			}
		}
	}

	func setupSelectedRegionsForTesting() {
		if isUITesting, LaunchArguments.statistics.maximumRegionsSelected.boolValue {
			let heidelbergRegion = LocalStatisticsRegion(
									   federalState: .badenWürttemberg,
									   name: "Heidelberg",
									   id: "1432",
									   regionType: .administrativeUnit
								   )
			let mannheimRegion = LocalStatisticsRegion(
									   federalState: .badenWürttemberg,
									   name: "Mannheim",
									   id: "1434",
									   regionType: .administrativeUnit
								   )
			let badenWurttembergRegion = LocalStatisticsRegion(
									   federalState: .badenWürttemberg,
									   name: "Baden Württemberg",
									   id: "2342",
									   regionType: .administrativeUnit
								   )
			let hessenRegion = LocalStatisticsRegion(
									   federalState: .badenWürttemberg,
									   name: "Hessen",
									   id: "1144",
									   regionType: .administrativeUnit
								   )
			let rheinlandPfalzRegion = LocalStatisticsRegion(
									   federalState: .badenWürttemberg,
									   name: "Rheinland Pfalz",
									   id: "1456",
									   regionType: .administrativeUnit
								   )
			store.selectedLocalStatisticsRegions = [heidelbergRegion, mannheimRegion, badenWurttembergRegion, hessenRegion, rheinlandPfalzRegion]
		}
	}
	#endif
}
