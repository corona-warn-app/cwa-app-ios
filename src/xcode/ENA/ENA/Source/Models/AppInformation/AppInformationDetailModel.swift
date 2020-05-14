//
//  AppInformationDetailModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


struct AppInformationDetailModel {
	let headerImage: UIImage?
	let content: [Content]
}


extension AppInformationDetailModel {
	enum Content {
		case headline(text: String)
		case body(text: String)
		case bold(text: String)
		case small(text: String)
		case tiny(text: String)
		case phone(text: String, number: String)
		case seperator
	}
}
