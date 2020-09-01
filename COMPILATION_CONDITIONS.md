# Compilation Conditions

Our code uses several (custom) [ compilation conditions](https://help.apple.com/xcode/mac/11.4/#/itcaec37c2a6) (search for `SWIFT_ACTIVE_COMPILATION_CONDITIONS`).

| Compilation Condition | Description |
|---|---|
| `RELEASE` | `true` if the app was built in release-mode. We mainly use this flag to disable certain features (developer menu, logging, …) for production. If you want to disable a certain feature for production you should use `#if !RELEASE` as opposed to `#if DEBUG`. |
| `UITESTING` | `true` is the app was built in order to execute UI tests. We mainly use this flag to have slightly different code paths which is required when generating screenshots or testing certain edge conditions.  |
| `COMMUNITY` | `true` is the *Community* build configuration/schema has been selected. The *Community* configuration enables other developers to run the app in Simulator. |
| `USE_DEV_PK_FOR_SIG_VERIFICATION` | `true` if the app should use the dev-public keys for the signature verfification. This is only set for testig and during development. In case this is set mistakenly to `true` the app simply stops working. |
| `DISABLE_CERTIFICATE_PINNING` | `true` if certificate pinning should be disabled. This is **NEVER EVER** set for builds that will end up in the App Store. We only use this for debugging purposes. |

