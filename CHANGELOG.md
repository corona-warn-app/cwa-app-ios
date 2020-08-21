# Changelog

## v1.2.0 (03/08/2020)

#### Bug fixes
-  Fix text of high risk information [#994](https://github.com/corona-warn-app/cwa-app-ios/pull/994)
-  Fix AppNavigationController navigation bar transparency [#926](https://github.com/corona-warn-app/cwa-app-ios/pull/926)
-  Test result screen button state fix [#870](https://github.com/corona-warn-app/cwa-app-ios/pull/870)
-  Make risk encounter detail text show amount of days since last exposure [#923](https://github.com/corona-warn-app/cwa-app-ios/pull/923)
-  Display underline in ENATanInput when character is invalid [#884](https://github.com/corona-warn-app/cwa-app-ios/pull/884)
-  Make activate cell support voice over [#904](https://github.com/corona-warn-app/cwa-app-ios/pull/904)
-  Fix blank Data Privacy page after 5 minutes without user interaction [#825](https://github.com/corona-warn-app/cwa-app-ios/pull/825)
-  Updating of home cells  [#822](https://github.com/corona-warn-app/cwa-app-ios/pull/822)
-  Bring back lost translation keys for Turkish and English[#935](https://github.com/corona-warn-app/cwa-app-ios/pull/935)

#### New features

-  Translation update and integrate three new languages (Romanian, Bulgarian and Polish) [#905](https://github.com/corona-warn-app/cwa-app-ios/pull/905), [#933](https://github.com/corona-warn-app/cwa-app-ios/pull/933), [#961](https://github.com/corona-warn-app/cwa-app-ios/pull/961), [#1006](https://github.com/corona-warn-app/cwa-app-ios/pull/1006)
-  Add interactivity to links in App Settings Imprint (Legal) Screen [#833](https://github.com/corona-warn-app/cwa-app-ios/pull/833)
-  Loading state  for risk cell [#873](https://github.com/corona-warn-app/cwa-app-ios/pull/873)
-  Tracing Status Animation [#821](https://github.com/corona-warn-app/cwa-app-ios/pull/821)
-  Certificate pinning for download server [#930](https://github.com/corona-warn-app/cwa-app-ios/pull/930), [#951](https://github.com/corona-warn-app/cwa-app-ios/pull/951)

#### Enhancements

-  Improved wording for exposures [#979](https://github.com/corona-warn-app/cwa-app-ios/pull/979)
-  Translation updates [#931](https://github.com/corona-warn-app/cwa-app-ios/pull/931)
-  Force tan input field to be ordered left-to-right even for RTL languages [#919](https://github.com/corona-warn-app/cwa-app-ios/pull/919)
-  Background Fetching Disabled alert [#883](https://github.com/corona-warn-app/cwa-app-ios/pull/883)
-  Make configurators hashable [#859](https://github.com/corona-warn-app/cwa-app-ios/pull/859)
-  Add home screen risk cell update button countdown [#866](https://github.com/corona-warn-app/cwa-app-ios/pull/866)
-  ExposureDetectionViewController refresh countdown [#838](https://github.com/corona-warn-app/cwa-app-ios/pull/838)

#### Others

-  Exposure submission coordinator [#910](https://github.com/corona-warn-app/cwa-app-ios/pull/910)
-  Remove backend urls from settings [#875](https://github.com/corona-warn-app/cwa-app-ios/pull/875)

---

## v1.1.2 (24/07/2020)
#### Enhancements
-  Improve background task scheduling #946

---

## v1.1.1 (20/07/2020)
#### Bug Fixes

- Fix i18n issues [#913](https://github.com/corona-warn-app/cwa-app-ios/pull/913), [#915](https://github.com/corona-warn-app/cwa-app-ios/pull/915)

#### New features

-  Translation for turkish added [#773](https://github.com/corona-warn-app/cwa-app-ios/pull/773), [#829](https://github.com/corona-warn-app/cwa-app-ios/pull/829), [#925](https://github.com/corona-warn-app/cwa-app-ios/pull/925)

#### Enhancements

- Risk calculation explainer [#908](https://github.com/corona-warn-app/cwa-app-ios/pull/908)

---

## v1.0.7 (11/07/2020)
#### Bug fixes

-  Remove check that prevented from feeding the correct amount of files [#893](https://github.com/corona-warn-app/cwa-app-ios/pull/893)

---

## v1.0.6 (10/07/2020)
#### Bug fixes

-  Fix text on risk detail page [#879](https://github.com/corona-warn-app/cwa-app-ios/pull/879)

---

## v1.0.5 (09/07/2020)
#### Bug fixes
-  Home Screen Risk Cell Update on App start + Risk Calc Refinements [#874](https://github.com/corona-warn-app/cwa-app-ios/pull/874)
-  Fixed wrong implementation of shouldPerformExposureDetection [#869](https://github.com/corona-warn-app/cwa-app-ios/pull/869)
-  Risk Calculation Errors - Alert Refinement  [#868](https://github.com/corona-warn-app/cwa-app-ios/pull/868)
-  Error 13 mitigations [#863](https://github.com/corona-warn-app/cwa-app-ios/pull/863)
-  Fixes wrong days with tracing info on home screen [#849](https://github.com/corona-warn-app/cwa-app-ios/pull/849)
-  Exposure Submission Flow - Error Alert adjustments [#843](https://github.com/corona-warn-app/cwa-app-ios/pull/843)
-  Integrate new localized errors for exposurenotification settings [#840](https://github.com/corona-warn-app/cwa-app-ios/pull/840)
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
-  Localization: Use localized "OK" for error alerts [#662](https://github.com/corona-warn-app/cwa-app-ios/pull/662)
-  Fix: Minor mistakes in de localization [#664](https://github.com/corona-warn-app/cwa-app-ios/pull/664)
-  Fixed typo in first screen (de) [#657](https://github.com/corona-warn-app/cwa-app-ios/pull/657)

#### Enhancements

-  Added the missing localizations for the alerts. [#672](https://github.com/corona-warn-app/cwa-app-ios/pull/672)
-  Update ExposureSubmissionService.swift [#608](https://github.com/corona-warn-app/cwa-app-ios/pull/608)
-  Call requestRisk on sceneWillEnterForeground [#607](https://github.com/corona-warn-app/cwa-app-ios/pull/607)
-  ENAButton activity indicator for submission flow [#753](https://github.com/corona-warn-app/cwa-app-ios/pull/753)
-  ENAButton accessibility [#752](https://github.com/corona-warn-app/cwa-app-ios/pull/752)
-  Translation Changes in DE & EN [#786](https://github.com/corona-warn-app/cwa-app-ios/pull/786), [#743](https://github.com/corona-warn-app/cwa-app-ios/pull/743)
-  Improve submission handling [#609](https://github.com/corona-warn-app/cwa-app-ios/pull/609)

#### Others

-  Refactor Error Handling in Exposure Submission [#808](https://github.com/corona-warn-app/cwa-app-ios/pull/808)
-  Split background tasks on develop branch [#728](https://github.com/corona-warn-app/cwa-app-ios/pull/728)
-  Marked the "not implemented" initializers as "unavailable" (closes #681) [#682](https://github.com/corona-warn-app/cwa-app-ios/pull/682)
-  DetectionMode adjustments [#685](https://github.com/corona-warn-app/cwa-app-ios/pull/685)
-  Move all AccessibilityIdentifiers to central file (closes #707) [#713](https://github.com/corona-warn-app/cwa-app-ios/pull/713)
-  Removes unused client code - closes #714 [#715](https://github.com/corona-warn-app/cwa-app-ios/pull/715)
-  Removed dead code [#589](https://github.com/corona-warn-app/cwa-app-ios/pull/589)
-  Removed unused code, added tests, slight api improvements [#586](https://github.com/corona-warn-app/cwa-app-ios/pull/586)
-  KeyValue Store. [#541](https://github.com/corona-warn-app/cwa-app-ios/pull/541)
-  Test/exposure submission ui tests [#603](https://github.com/corona-warn-app/cwa-app-ios/pull/603)
-  Add tests for DynamicTableViewSpaceCell [#490](https://github.com/corona-warn-app/cwa-app-ios/pull/490)
-  Minor improvements [#654](https://github.com/corona-warn-app/cwa-app-ios/pull/654)
-  More HTTPClient Tests + (Small) Signature Verification Refactor [#605](https://github.com/corona-warn-app/cwa-app-ios/pull/605)

---

## 1.0.4 (03/07/2020)
#### Bug fixes
-  Fixed number of active days [#841](https://github.com/corona-warn-app/cwa-app-ios/pull/841)

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
