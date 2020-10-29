module.exports = {
    "dataSource": "prs",
    "ignoreLabels": ["on hold", "chore", "closed", "bug", "fix", "feature", "feature request", "enhancement", "UI polish, UX"],
    "ignoreIssuesWith": ["admin", "documentation", "tests", "promotion"],
    "onlyMilestones": true,
    "ignoreTagsWith": ["alpha", "beta"],
    "changelogFilename": "CHANGELOG.md",
    "groupBy": {
        "Bug fixes": ["bug", "fix"],
        "New features": ["feature", "feature request"],
        "Enhancements": ["enhancement"],
        "UX": ["UI polish, UX"],
        "Others": ["..."]
    }
}
