# Contributing

## Code of Conduct

All members of the project community must abide by the [Contributor Covenant, version 2.0](CODE_OF_CONDUCT.md).
Only by respecting each other we can develop a productive, collaborative community.
Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting [corona-warn-app.opensource@sap.com](mailto:corona-warn-app.opensource@sap.com) and/or a project maintainer.

We appreciate your courtesy of avoiding political questions here. Issues which are not related to the project itself will be closed by our community managers.

## Engaging in Our Project

We use GitHub to manage reviews of pull requests.

* If you are a new contributor, see: [Steps to Contribute](#steps-to-contribute)

* Before opening a new Pull Request, create an issue that describes the problem you would like to solve or the code that should be enhanced. Please note that you are willing to work on that issue.

* The team will review the issue and decide whether it should be implemented as a Pull Request. In that case, they will assign the issue to you. If the team decides against picking up the issue, it will be closed with a proper explanation.

* Relevant coding style guidelines are available in the respective sub-repositories as they are programming language-dependent.

## Steps to Contribute

Should you wish to work on an existing issue, please claim it first by commenting on the GitHub issue that you want to work on. This is to prevent duplicated efforts from other contributors on the same issue.

Only start working on the Pull Request after the team assigned the issue to you to avoid unnecessary efforts.

If you have questions about one of the issues, please comment on them, and one of the maintainers will clarify.

We kindly ask you to follow the [Pull Request Checklist](#Pull-Request-Checklist) to ensure reviews can happen accordingly.

## Contributing Code

You are welcome to contribute code in order to fix a bug or to implement a new feature that is logged as an issue.

Only start working on the Pull Request after the team assigned the issue to you to avoid unnecessary efforts.

The following rule governs code contributions:

* Contributions must be licensed under the [Apache 2.0 License](./LICENSE)

## Contributing Documentation

You are welcome to contribute documentation to the project.

The following rule governs documentation contributions:

* Contributions must be licensed under the same license as code, the [Apache 2.0 License](./LICENSE)

## Pull Request Checklist

* Branch from the latest `release` branch (i.e. the default branch of the Github repository) and, if needed, rebase to the upstream branch before submitting your pull request. If your PR doesn't merge cleanly, you may be asked to rebase your changes.

* Commits should be as small as possible while ensuring that each commit is correct independently (i.e., each commit should compile and pass tests).

* Test your changes as thoroughly as possible before you commit them. Preferably, automate your test by unit/integration tests. If tested manually, provide information about the test scope in the PR description (e.g. “Test passed: Upgrade version from 0.42 to 0.42.23.”).

* Create _Work In Progress [WIP]_ pull requests only if you need clarification or an explicit review before you can continue your work item.

### Opening Pull Request

1.  Set title.
Format: `{task_name} (closes #{issue_number})`. For example: `Use logger (closes #41)`.
2. Set target branch.
All feature branches should branch from the latest ```release``` branch, so the target should also be this ```release``` branch.
3.  Set description.
Describe what is the pull request about and add some bullet points describing what’s changed and why. Also, any instructions how to review/test/etc. should be written here. The goal is to make it easier for reviewers to review the pull request, and to let them know what they should be careful of, what they should focus on, etc.
4. Open the pull request.
5. [Only applicable for members of the SAP development team] Open the team chat in Microsoft Teams and notify team members that the pull request is ready for review.
Describe what’s the pull request about in one short sentence and post the link to the pull request. Additionally, describe how big the pull request is. The goal of this step is to provide team members with some information about the pull request to prevent them having to open the link to get the basic information about it.
**Note: Every message like this in the team chat is a kind request to team members to review the pull request. These messages should not be ignored. If the message is ignored, the pull request creator should remind team members. Ultimately, stale pull request should/have to be mentioned in dailies.**

### Reviewing a Pull Request

1. Every pull request should be reviewed exactly by 2 reviewers. Ideally, when starting the review, a reviewer should write a comment in the pull request that she/he started the review (and also when done). After 2 reviewers already started the review, someone else is allowed to comment/review only when she/he has noticed something that’s terribly wrong and/or will break things. The idea is to prevent more than 2 team members doing the review, but to leave opened the possibility for anyone to prevent things from breaking.
2. Every comment on pull request should be accepted as a change request and should be discussed. When something is optional, it should be noted in the comment.
3. When a change is requested and a conversation is opened, only the reviewer that opened the conversation should be allowed to resolve it, which is done when the reviewer is settled with the answer/change. **The creator of the pull request should never resolve conversations.** If the reviewer and the creator cannot agree, the creator is the one that is right, except the reviewer is part @cwa-app-ios-members and the creator isn't (but still she/he should not be the one that resolves the conversation). Code reviewers are responsible to comment on the things they think are wrong, but ultimately the person responsible for the code is the pull request creator, as she/he is acting as the owner of that story.
4. When some requested change is implemented by the creator, ideally the link should be posted to the commit where the change has happened. For example: `Done here{link-to-the-commit}`.
5. A reviewer should resolve all conversations that she/he has started before approving the pull request.
6. When there are two approvals (and all conversations are resolved), the pull request can be merged.
7. Every big change, like merge, that happens after 2 approvals, should be followed by a kind request by the pull request creator to reviewers to have a look at the newly added code.

* If your patch is not getting reviewed or you need a specific person to review it, you can @-reply a reviewer asking for a review in the pull request or a comment, or you can ask for a review by contacting us via [email](mailto:corona-warn-app.opensource@sap.com).

* Post review:
  * If a review requires you to change your commit(s), please test the changes again.
  * Amend the affected commit(s) and force push onto your branch.
  * Set respective comments in your GitHub review to resolved.
  * Create a general PR comment to notify the reviewers that your amendments are ready for another round of review.

## Issues and Planning

* We use GitHub issues to track bugs and enhancement requests.

* Please provide as much context as possible when you open an issue. The information you provide must be comprehensive enough to reproduce that issue for the assignee. Therefore, contributors should use but aren't restricted to the issue template provided by the project maintainers.

* When creating an issue, try using one of our issue templates which already contain some guidelines on which content is expected to process the issue most efficiently. If no template applies, you can of course also create an issue from scratch.
