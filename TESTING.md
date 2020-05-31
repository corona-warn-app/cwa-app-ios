**Table of Contents**

- [Executing Tests](#executing-tests)
- [Writing Tests](#writing-tests)
  - [Rationale](#rationale)
  - [Getting Started](#getting-started)
  - [Untestable Code](#untestable-code)

---

## Executing Tests
You can execute the tests by running the following command from the root of this project:

```
cd src/xcode && fastlane test
```

Alternatively you can execute the tests by hitting ⌘U within Xcode.

## Writing Tests

### Rationale
In order to keep things simple we use [XCTest](https://developer.apple.com/documentation/xctest) as the basis for our tests. Tests are put into directories called `__tests__`. We want to have to tests as close as possible to the code they actually test. 

Once things have stabilized we would like to split the *app target* up into multiple smaller frameworks. Each framework would then have it's own test target. By having multiple *local* `__tests__`-directories we accomentate this forseeing change to some extent today.

Having multiple local `__tests__`-directories also makes it easier to see where tests are still missing.

### Getting Started
There is a dedicated label called **tests** for issues that ask for tests. If you want to contribute tests to this project it is a good idea to look at **[the list of tests that still need to be done](https://github.com/corona-warn-app/cwa-app-ios/issues?q=is%3Aissue+is%3Aopen+label%3A%22tests%22)**. Simply pick an issue, write tests for it, open a PR and wait for feedback.

### Untestable Code
Parts of the existing code may not be testable. If you spot code that you feel is not testable please open an issue and report this as a bug.