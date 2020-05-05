//
//  AppStrings.swift
//  ENA
//
//  Created by Zildzic, Adnan on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

struct AppStrings {
    struct Commom {
        static let alertTitleGeneral = NSLocalizedString("AlertTitleGeneral", comment: "")
        static let alertMessageGeneral = NSLocalizedString("AlertMessageGeneral", comment: "")
        static let alertActionOk = NSLocalizedString("AlertActionOk", comment: "")
    }

    struct ExposureSubmission {
        static let title = NSLocalizedString("SelfExposure_Title", comment: "")
        static let description = NSLocalizedString("SelfExposure_Description", comment: "")
        static let submit = NSLocalizedString("SelfExposure_Submit", comment: "")
        static let navigationBarTitle = NSLocalizedString("SelfExposure_Nav_Title", comment: "")
    }

    struct ExposureSubmissionTanEntry {
        static let title = NSLocalizedString("SelfExposure_TANEntry_Title", comment: "")
        static let description = NSLocalizedString("SelfExposure_TANEntry_Description", comment: "")
        static let submit = NSLocalizedString("SelfExposure_TANEntry_Submit", comment: "")
    }

    struct ExposureSubmissionConfirmation {
        static let title = NSLocalizedString("SelfExposure_Confirmation_Title", comment: "")
        static let description = NSLocalizedString("SelfExposure_Confirmation_Description", comment: "")
        static let submit = NSLocalizedString("SelfExposure_Confirmation_Submit", comment: "")
    }

    struct ExposureDetection {
        static let lastContactDays = NSLocalizedString("lastDays", comment: "")
        static let lastContactHours = NSLocalizedString("lastHours", comment: "")
        static let lastContactTitle = NSLocalizedString("ExposureDetection_lastContactTitle", comment: "")
        static let synchronize = NSLocalizedString("ExposureDetection_synchronize", comment: "")

        static let info = NSLocalizedString("ExposureDetection_info", comment: "")
        static let infoText = NSLocalizedString("ExposureDetection_infoText", comment: "")
        static let lastSync = NSLocalizedString("unknown_time", comment: "")
        static let nextSync = NSLocalizedString("nextSync", comment: "")
    }

    struct Settings {
        static let trackingStatusActive = NSLocalizedString("status_Active", comment: "")
        static let trackingStatusInactive = NSLocalizedString("status_Inactive", comment: "")
    }

    struct Onboarding {
        static let onboardingFinish = NSLocalizedString("onboarding_button_finish", comment: "")
        static let onboardingNext = NSLocalizedString("onboarding_button_next", comment: "")
    }
}
