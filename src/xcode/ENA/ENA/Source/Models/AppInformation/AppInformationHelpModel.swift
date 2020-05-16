//
//  AppInformationHelpModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation


struct AppInformationHelpModel {
	typealias Question = (title: String, details: AppInformationDetailModel)
	typealias Section = (sectionTitle: String, questions: [Question])
	
	
	private let sections: [Section]
	
	
	init(questions: [Section]) {
		self.sections = questions
	}
	
	
	var numberOfSections: Int { sections.count }
	
	
	func title(for section: Int) -> String {
		return sections[section].sectionTitle
	}
	
	
	func questions(in section: Int) -> [Question] {
		return sections[section].questions
	}
	
	
	func question(_ index: Int, in section: Int) -> Question {
		return sections[section].questions[index]
	}
}
