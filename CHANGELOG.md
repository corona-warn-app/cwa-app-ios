# Changelog

## 1.0.4 (03/07/2020)
#### Bug fixes
-  Fixed number of active days [#841](https://github.com/corona-warn-app/cwa-app-ios/pull/841)
---

## v1.0.5-dev (02/07/2020)
#### Bug fixes

-  Fixed deadlock when clicking on risk cell (closes #747) [#746](https://github.com/corona-warn-app/cwa-app-ios/pull/746)
-  Nutzung Chapter 7 link (de) updated [#779](https://github.com/corona-warn-app/cwa-app-ios/pull/779)
-  Remove invite friends footer translucency [#751](https://github.com/corona-warn-app/cwa-app-ios/pull/751)
-  Submission Flow Navigation [#687](https://github.com/corona-warn-app/cwa-app-ios/pull/687)
-  EXPOSUREAPP-1531 Sharing function is missing explanation text [#745](https://github.com/corona-warn-app/cwa-app-ios/pull/745)
-  show indicator progress on the risk cell [#634](https://github.com/corona-warn-app/cwa-app-ios/pull/634)
-  Fixed: Link to English FAQs when running the App in English (closes #643) [#644](https://github.com/corona-warn-app/cwa-app-ios/pull/644)
-  Fix ActionTableViewCell accessibility issue (closes #670) [#673](https://github.com/corona-warn-app/cwa-app-ios/pull/673)
-  Only request user notifications where necessary [#674](https://github.com/corona-warn-app/cwa-app-ios/pull/674)
-  change timeout interval [#676](https://github.com/corona-warn-app/cwa-app-ios/pull/676)
-  Disable iTunes file sharing for the app (closes #700) [#705](https://github.com/corona-warn-app/cwa-app-ios/pull/705)
-  Fixed risk view [#718](https://github.com/corona-warn-app/cwa-app-ios/pull/718)
-  Fix height of manual refresh button on home screen. [#606](https://github.com/corona-warn-app/cwa-app-ios/pull/606)
-  Fix unknown out dated card button [#611](https://github.com/corona-warn-app/cwa-app-ios/pull/611)
-  Fix unknown outdated risk detail screen [#613](https://github.com/corona-warn-app/cwa-app-ios/pull/613)
-  Set earliestBeginTime to nil [#612](https://github.com/corona-warn-app/cwa-app-ios/pull/612)
-  Remove error when submitting 0 keys [#800](https://github.com/corona-warn-app/cwa-app-ios/pull/800)
-  Mitteilungen - image not focusable with voice over (closes 1427) [#725](https://github.com/corona-warn-app/cwa-app-ios/pull/725)
-  Onboarding - Risikoermittlung - logic flaw (EXPOSUREAPP-1475) [#517](https://github.com/corona-warn-app/cwa-app-ios/pull/517)

#### New features

-  ENAButton activity indicator for submission flow [#753](https://github.com/corona-warn-app/cwa-app-ios/pull/753)
-  ENAButton accessibility [#752](https://github.com/corona-warn-app/cwa-app-ios/pull/752)
-  Translation for turkish added [#773](https://github.com/corona-warn-app/cwa-app-ios/pull/773), [#829](https://github.com/corona-warn-app/cwa-app-ios/pull/829)

#### Enhancements

-  Added the missing localizations for the alerts. [#672](https://github.com/corona-warn-app/cwa-app-ios/pull/672)
-  Update ExposureSubmissionService.swift [#608](https://github.com/corona-warn-app/cwa-app-ios/pull/608)
-  Call requestRisk on sceneWillEnterForeground [#607](https://github.com/corona-warn-app/cwa-app-ios/pull/607)

#### Others

-  Refactor Error Handling in Exposure Submission [#808](https://github.com/corona-warn-app/cwa-app-ios/pull/808)
-  Translation Changes in DE & EN [#786](https://github.com/corona-warn-app/cwa-app-ios/pull/786)
-  Split background tasks on develop branch [#728](https://github.com/corona-warn-app/cwa-app-ios/pull/728)
-  Translation [#743](https://github.com/corona-warn-app/cwa-app-ios/pull/743)
-  Marked the "not implemented" initializers as "unavailable" (closes #681) [#682](https://github.com/corona-warn-app/cwa-app-ios/pull/682)
-  DetectionMode adjustments [#685](https://github.com/corona-warn-app/cwa-app-ios/pull/685)
-  Move all AccessibilityIdentifiers to central file (closes #707) [#713](https://github.com/corona-warn-app/cwa-app-ios/pull/713)
-  Removes unused client code - closes #714 [#715](https://github.com/corona-warn-app/cwa-app-ios/pull/715)
-  Removed dead code [#589](https://github.com/corona-warn-app/cwa-app-ios/pull/589)
-  Removed unused code, added tests, slight api improvements [#586](https://github.com/corona-warn-app/cwa-app-ios/pull/586)
-  KeyValue Store. [#541](https://github.com/corona-warn-app/cwa-app-ios/pull/541)
-  Localization: Use localized "OK" for error alerts [#662](https://github.com/corona-warn-app/cwa-app-ios/pull/662)
-  Fix: Minor mistakes in de localization [#664](https://github.com/corona-warn-app/cwa-app-ios/pull/664)
-  Improve submission handling [#609](https://github.com/corona-warn-app/cwa-app-ios/pull/609)
-  Test/exposure submission ui tests [#603](https://github.com/corona-warn-app/cwa-app-ios/pull/603)
-  Fixed typo in first screen (de) [#657](https://github.com/corona-warn-app/cwa-app-ios/pull/657)
-  Add tests for DynamicTableViewSpaceCell [#490](https://github.com/corona-warn-app/cwa-app-ios/pull/490)
-  Minor improvements [#654](https://github.com/corona-warn-app/cwa-app-ios/pull/654)
-  More HTTPClient Tests + (Small) Signature Verification Refactor [#605](https://github.com/corona-warn-app/cwa-app-ios/pull/605)

---

## v1.0.3 (01/07/2020)
#### Bug fixes

-  Fix number of days since last exposure [#811](https://github.com/corona-warn-app/cwa-app-ios/pull/811)
-  Fix pruning of tracing history [#807](https://github.com/corona-warn-app/cwa-app-ios/pull/807), [#812](https://github.com/corona-warn-app/cwa-app-ios/pull/812)


---

## v1.0.2.2 (15/06/2020)

#### Bug fixes

-  [Bug] Fix height of manual refresh button on home screen. [#606](https://github.com/corona-warn-app/cwa-app-ios/pull/606)
-  Fix unknown out dated card button [#611](https://github.com/corona-warn-app/cwa-app-ios/pull/611)
-  [Bug] Fix unknown outdated risk detail screen [#613](https://github.com/corona-warn-app/cwa-app-ios/pull/613)
-  [HOTFIX] Set earliestBeginTime to nil [#612](https://github.com/corona-warn-app/cwa-app-ios/pull/612)

#### Enhancements

-  Update ExposureSubmissionService.swift [#608](https://github.com/corona-warn-app/cwa-app-ios/pull/608)
-  [HOTFIX] Call requestRisk on sceneWillEnterForeground [#607](https://github.com/corona-warn-app/cwa-app-ios/pull/607)

#### Others

- [**chore**] removed dead code [#589](https://github.com/corona-warn-app/cwa-app-ios/pull/589)

---

## 1.0.2.1 (15/06/2020)

---

## Release (13/06/2020)

---

## Beta Patch 2 - Production (12/06/2020)

---

## Beta Patch 1 - Production (11/06/2020)

---

## Beta Patch 4 (11/06/2020)

---

## Beta Patch 3 (11/06/2020)

---

## Beta Patch 2 (10/06/2020)

---

## Beta Release - Production (10/06/2020)

---

## Beta Patch 1 (09/06/2020)

---

## Beta Release (08/06/2020)

---

## Alpha - v0.8.2 (1290) (08/06/2020)

---

## Alpha - v0.8.2 (1250) (07/06/2020)

---

## Alpha - v0.8.2 (1226) (06/06/2020)

---

## Alpha - v0.8.2 (840) (06/06/2020)

---

## Alpha - v0.8.2 (04/06/2020)

---

## Alpha - v0.8.1 (04/06/2020)
