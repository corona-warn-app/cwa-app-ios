fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios update_licenses

```sh
[bundle exec] fastlane ios update_licenses
```

Update license file

### ios build_for_testing

```sh
[bundle exec] fastlane ios build_for_testing
```

Build project for testing

### ios test_without_building

```sh
[bundle exec] fastlane ios test_without_building
```

Runs unit tests without building

### ios build_community

```sh
[bundle exec] fastlane ios build_community
```

Build project (Community)

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint code

### ios screenshot

```sh
[bundle exec] fastlane ios screenshot
```

Create (localized) screenshots

### ios betaRelease

```sh
[bundle exec] fastlane ios betaRelease
```

Build and upload for testing

### ios adHocDistribution

```sh
[bundle exec] fastlane ios adHocDistribution
```

Ad hoc distribution

### ios updateDocs

```sh
[bundle exec] fastlane ios updateDocs
```

Update GitHub Pages

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
