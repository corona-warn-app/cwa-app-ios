module.exports = {
    "dataSource": "prs",
    "prefix": "v",
    "ignoreLabels": ["on hold", "closed", "bug", "fix", "feature", "feature request", "enhancement", "UI polish, UX"],
    "ignoreIssuesWith": ["admin", "documentation", "tests"],
    "onlyMilestones": false,
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
