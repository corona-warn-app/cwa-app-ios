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

import Foundation

struct AppInformationHelpModel {
	typealias Question = (title: String, details: AppInformationDetailModel)
	typealias Section = (sectionTitle: String, questions: [Question])
	
	private let sections: [Section]
	
	init(questions: [Section]) {
		sections = questions
	}
	
	var numberOfSections: Int { sections.count }
	
	func title(for section: Int) -> String {
		sections[section].sectionTitle
	}
	
	func questions(in section: Int) -> [Question] {
		sections[section].questions
	}
	
	func question(_ index: Int, in section: Int) -> Question {
		sections[section].questions[index]
	}
}
