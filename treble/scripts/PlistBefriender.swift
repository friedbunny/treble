#!/usr/bin/env xcrun -sdk macosx swift

import Foundation

let APP_PREFIX = "TRBL"
let APP_VERSION_KEY = APP_PREFIX + "VersionString"
let SDK_VERSION_KEY = APP_PREFIX + "MapboxSDKVersionString"

// MARK: - Create version strings from plists

func appVersionString(fromPlist path: String) -> String {
    if let dict = NSDictionary(contentsOfFile: path) {
        #if swift(>=3)
            if let version = dict.value(forKey: "CFBundleShortVersionString"), let build = dict.value(forKey: "CFBundleVersion") {
                return "\(version) (\(build))"
            }
        #else
            if let version = dict.valueForKey("CFBundleShortVersionString"), let build = dict.valueForKey("CFBundleVersion") {
            return "\(version) (\(build))"
            }
        #endif
    } else {
        print("Failed to create app version string from keys in \(path)")
    }
    return ""
}

func SDKVersionString(fromPlist path: String) -> String {
    if let dict = NSDictionary(contentsOfFile: path),
        let version = dict.value(forKey: "MGLSemanticVersionString"),
        let commit: String = dict.value(forKey: "MGLCommitHash") as? String {
        #if swift(>=3)
            return "\(version) (\(commit.truncate(length: 7)))"
        #else
            return "\(version) (\(commit.truncate(7)))"
        #endif
    } else {
        print("Failed to create SDK version string from keys in \(path)")
    }
    return ""
}

extension String {
    func truncate(length: Int) -> String {
        #if swift(>=3.2)
            return String(prefix(length))
        #else
            return String(characters.prefix(length))
        #endif
    }
}

// MARK: - Manipulate Settings.bundle plist

func implantVersionStringsInSettingsBundlePlist(appVersion: String, SDKVersion: String, path: String) {
    // load the bundle’s plist as a dictionary
    if let mainDict = NSMutableDictionary(contentsOfFile: path) {
        var replacedKeyCount = 0
        let preferenceSpecifierKey: NSString = "PreferenceSpecifiers"

        let preferenceSpecifiers = mainDict.object(forKey: preferenceSpecifierKey) as! NSMutableArray

        for (index, specifier) in preferenceSpecifiers.enumerated() {
            let specificerDict: NSDictionary = specifier as! NSDictionary
            if let key: String = specificerDict.object(forKey: "Key") as? String {
                if key == APP_VERSION_KEY || key == SDK_VERSION_KEY {
                    let stringToInsert = (key == APP_VERSION_KEY) ? appVersion : SDKVersion
                    let replacementSpecificer = specificerDict.mutableCopy() as! NSMutableDictionary
                    replacementSpecificer.setValue(stringToInsert, forKey: "DefaultValue")
                    preferenceSpecifiers[index] = replacementSpecificer.copy()
                    replacedKeyCount += 1
                }
            }
        }

        if replacedKeyCount != 2 {
            print("Failed to replace \(APP_VERSION_KEY) and/or \(SDK_VERSION_KEY)")
            exit(1)
        }

        // replace PreferenceSpecifiers with our updated array
        mainDict.setObject(preferenceSpecifiers, forKey: preferenceSpecifierKey)

        mainDict.write(toFile: path, atomically: false)
        print("Replaced Settings.bundle plist at path: \(path)")
    } else {
        print("Failed to find Settings.bundle plist at path: \(path)")
    }
}

// MARK: - Arguments and script

print("Befriending plists.")

let arguments = CommandLine.arguments

if arguments.count != 4 {
    print("You must supply the paths for this project’s Info.plist, its Settings.bundle plist, and Mapbox.framework")
    print("Example: \(arguments[0]) \"${INFOPLIST_FILE}\" \"${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/Settings.bundle/Root.plist\" \"${PODS_ROOT}/Mapbox-iOS-SDK/dynamic/Mapbox.framework\"")
    exit(1)
}

let infoPlistPath = arguments[1]
let settingsPlistPath = arguments[2]
let SDKFrameworkPlistPath = "\(arguments[3])/Info.plist"

let appVersion = appVersionString(fromPlist: infoPlistPath)
print ("App version: \(appVersion)")

let SDKVersion = SDKVersionString(fromPlist: SDKFrameworkPlistPath)
print ("Mapbox.framework version: \(SDKVersion)")

implantVersionStringsInSettingsBundlePlist(appVersion: appVersion, SDKVersion: SDKVersion, path: settingsPlistPath)
