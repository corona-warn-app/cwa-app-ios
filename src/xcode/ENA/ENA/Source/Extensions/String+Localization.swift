//
//  String+Localization.swift
//  ENA
//
//  Created by Kienle, Christian on 08.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension String {
	var localized: String {
		return self.localized(tableName: nil)
	}
	
    func localized(tableName: String? = nil) -> String {
        return NSLocalizedString(self, tableName: tableName, comment: "")
    }
}
