//
//  AppStrings.swift
//  Kurzwahl2020
//
//  Created by tcfos on 25.12.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import Foundation

enum AppStrings {
    enum settings {
        static let fontSize = NSLocalizedString("Settings_FontSize", comment: "");
        static let fontSizeMetric = NSLocalizedString("Settings_SizeMetric", comment: "");
        static let about = NSLocalizedString("Settings_About", comment: "");
        static let data_Privacy_Statement = NSLocalizedString("Data_Privacy_Statement", comment: "");
        static let settings = NSLocalizedString("settings", comment: "");
        static let help = NSLocalizedString("settings_help", comment: "");
        static let colors = NSLocalizedString("settings_colors", comment: "");
    }

    enum contacts {
        static let contacts = NSLocalizedString("contacts", comment: "Navigation bar title");
        static let selectContact = NSLocalizedString("contactView_selectContact", comment: "Navigation bar title");
        static let cancel = NSLocalizedString("contactView_cancel", comment: "Navigation bar Cancel button");
    }
    
    enum edit {
        static let contacts = NSLocalizedString("contacts", comment: "Navigation bar title");
        static let cancel = NSLocalizedString("editView_cancel", comment: "Navigation bar Cancel button");
    }
}
