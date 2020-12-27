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
        static let phoneNumbers = NSLocalizedString("phone_numbers", comment: "Navigation bar title");
        static let contact_detail_cancel = NSLocalizedString("contact_detail_cancel", comment: "Navigation bar Cancel button");
    }
    
    enum edit {
        static let contacts = NSLocalizedString("contacts", comment: "Navigation bar title");
        static let cancelButton = NSLocalizedString("edit_cancelButton", comment: "Navigation bar Cancel button");
        static let enterNameAndNumber = NSLocalizedString("edit_enterNameAndNumber", comment: "");
        static let name = NSLocalizedString("edit_name", comment: "");
        static let number = NSLocalizedString("edit_number", comment: "");
        static let clear = NSLocalizedString("edit_clear", comment: "");
        static let ok = NSLocalizedString("edit_ok", comment: "");
    }
    
    // AskForAccessToContactsView
    enum askForAccess {
        static let heading1 = NSLocalizedString("askForAccess_heading1", comment: "");
        static let paragraph1 = NSLocalizedString("askForAccess_paragraph1", comment: "");
        static let heading2 = NSLocalizedString("askForAccess_heading2", comment: "");
        static let paragraph2 = NSLocalizedString("askForAccess_paragraph2", comment: "");
        static let heading3 = NSLocalizedString("askForAccess_heading3", comment: "");
        static let paragraph3 = NSLocalizedString("askForAccess_paragraph3", comment: "");
        static let backButton = NSLocalizedString("askForAccess_backButton", comment: "");
    }
    
    enum about {
        static let back = NSLocalizedString("about_back", comment: "");
        static let cbc36 = NSLocalizedString("about_cbc36", comment: "");
        static let cbc24 = NSLocalizedString("about_cbc24", comment: "");
        static let copyright = NSLocalizedString("about_copyright", comment: "");
    }
    
    enum privacyPolicy {
        static let heading1 = NSLocalizedString("privacy_policy_heading1", comment: "");
        static let paragraph1 = NSLocalizedString("privacy_policy_paragraph1", comment: "");
        static let backButton = NSLocalizedString("privacy_policy_backButton", comment: "");
    }
       
    enum home {
        static let edit = NSLocalizedString("home_edit", comment: "");
        static let clear = NSLocalizedString("home_clear", comment: "");
        static let callNumber = NSLocalizedString("home_callNumber", comment: "");
        static let settings = NSLocalizedString("home_settings", comment: "");
    }
    
    enum color {
        static let selectColor = NSLocalizedString("color_selectScreen", comment: "");
        static let selectPalette = NSLocalizedString("color_selectPalette", comment: "");
        static let backButton = NSLocalizedString("color_backButton", comment: "");
    }
    
    enum palette {
        static let summerTime = NSLocalizedString("palette_summerTime", comment: "");
    }
}
