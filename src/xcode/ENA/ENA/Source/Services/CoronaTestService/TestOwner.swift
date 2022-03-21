////
// 🦠 Corona-Warn-App
//

import Foundation

enum TestOwner: Equatable, Hashable, Codable {

	case user(testInfo: UserTestInfo)
	case familyMember(testInfo: FamilyMemberTestInfo)

}

struct FamilyMemberTestInfo: Equatable, Hashable {

	var displayName: String

}

struct UserTestInfo: Equatable, Hashable {

	var testedPerson: TestedPerson

	var isSubmissionConsentGiven: Bool
	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

}
