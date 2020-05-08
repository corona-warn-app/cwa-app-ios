//
//  AppStrings.swift
//  ENA
//
//  Created by Zildzic, Adnan on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

enum AppStrings {
    enum Commom {
        static let alertTitleGeneral = NSLocalizedString("Alert_TitleGeneral", comment: "")
        static let alertMessageGeneral = NSLocalizedString("Alert_MessageGeneral", comment: "")
        static let alertActionOk = NSLocalizedString("Alert_ActionOk", comment: "")
    }

    enum ExposureSubmission {
        static let title = NSLocalizedString("ExposureSubmission_Title", comment: "")
        static let description = NSLocalizedString("ExposureSubmission_Description", comment: "")
        static let submit = NSLocalizedString("ExposureSubmission_Submit", comment: "")
        static let navigationBarTitle = NSLocalizedString("ExposureSubmission_NavTitle", comment: "")
    }

    enum ExposureSubmissionTanEntry {
        static let title = NSLocalizedString("ExposureSubmissionTanEntry_Title", comment: "")
        static let description = NSLocalizedString("ExposureSubmissionTanEntry_Description", comment: "")
        static let submit = NSLocalizedString("ExposureSubmissionTanEntry_Submit", comment: "")
    }

    enum ExposureSubmissionConfirmation {
        static let title = NSLocalizedString("ExposureSubmissionConfirmation_Title", comment: "")
        static let description = NSLocalizedString("ExposureSubmissionConfirmation_Description", comment: "")
        static let submit = NSLocalizedString("ExposureSubmissionConfirmation_Submit", comment: "")
    }

    enum ExposureDetection {
        static let lastContactDays = NSLocalizedString("ExposureDetection_LastDays", comment: "")
        static let lastContactHours = NSLocalizedString("ExposureDetection_LastHours", comment: "")
        static let lastContactTitle = NSLocalizedString("ExposureDetection_LastContactTitle", comment: "")
        static let synchronize = NSLocalizedString("ExposureDetection_Synchronize", comment: "")

        static let info = NSLocalizedString("ExposureDetection_Info", comment: "")
        static let infoText = NSLocalizedString("ExposureDetection_InfoText", comment: "")
        static let lastSync = NSLocalizedString("ExposureDetection_LastSync", comment: "")
        static let nextSync = NSLocalizedString("ExposureDetection_NextSync", comment: "")
    }

    enum Settings {
        static let trackingStatusActive = NSLocalizedString("Settings_StatusActive", comment: "")
        static let trackingStatusInactive = NSLocalizedString("Settings_StatusInactive", comment: "")
        static let notificationStatusActive = NSLocalizedString("Settings_StatusActive", comment: "")
        static let notificationStatusInactive = NSLocalizedString("Settings_StatusInactive", comment: "")
    }

    enum Onboarding {
        static let onboardingFinish = NSLocalizedString("Onboarding_Finish", comment: "")
        static let onboardingNext = NSLocalizedString("Onboarding_Next", comment: "")
    }

    enum AppInformation {
        static let appInfoLabel1 = NSLocalizedString("App_Info", comment: "")
        static let appInfoLabel2 = NSLocalizedString("App_Privacy", comment: "")
        static let appInfoLabel3 = NSLocalizedString("App_Terms", comment: "")
        static let appInfoLabel4 = NSLocalizedString("App_Hotline", comment: "")
        static let appInfoLabel5 = NSLocalizedString("App_Help", comment: "")
        static let appInfoLabel6 = NSLocalizedString("App_Imprint", comment: "")
        static let labels = [appInfoLabel1, appInfoLabel2, appInfoLabel3, appInfoLabel4, appInfoLabel5, appInfoLabel6]
    }

    enum ExposureNotificationSetting {
        static let title = NSLocalizedString("ExposureNotificationSetting_TracingSettingTitle", comment: "The title of the view")
        static let enableTracing = NSLocalizedString("ExposureNotificationSetting_EnableTracing", comment: "The enable tracing")
        static let introductionTitle = NSLocalizedString("ExposureNotificationSetting_IntroductionTitle", comment: "The introduction label")
        static let introductionText = NSLocalizedString("ExposureNotificationSetting_IntroductionText", comment: "The introduction text")
    }

    enum Home {
        static let activateTitle = NSLocalizedString("Home_Activate_Title", comment: "")

        static let riskCardTitle = NSLocalizedString("Home_RiskCard_Title", comment: "")
        static let riskCardBody = NSLocalizedString("Home_RiskCard_Body", comment: "")
        static let riskCardDate = NSLocalizedString("Home_RiskCard_Date", comment: "")
        static let riskCardButton = NSLocalizedString("Home_RiskCard_Button", comment: "")

        static let submitCardTitle = NSLocalizedString("Home_SubmitCard_Title", comment: "")
        static let submitCardBody = NSLocalizedString("Home_SubmitCard_Body", comment: "")
        static let submitCardButton = NSLocalizedString("Home_SubmitCard_Button", comment: "")

        static let settingsCardTitle = NSLocalizedString("Home_SettingsCard_Title", comment: "")

        static let infoCardShareTitle = NSLocalizedString("Home_InfoCard_ShareTitle", comment: "")
        static let infoCardShareBody = NSLocalizedString("Home_InfoCard_ShareBody", comment: "")
        static let infoCardAboutTitle = NSLocalizedString("Home_InfoCard_AboutTitle", comment: "")
        static let infoCardAboutBody = NSLocalizedString("Home_InfoCard_AboutBody", comment: "")
    }
}
