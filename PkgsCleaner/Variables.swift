//  Variables.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-05-14.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//
import Foundation
import Cocoa
// Disable Smart Quotes for the output FinalOutPutTextField
// https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
// Add this to the InterfaceBuilder File (IB)
// automaticQuoteSubstitutionEnabled  Boolean Value Unchecked
// automaticDashSubstitutionEnabled Boolean Value Unchecked
// automaticTextReplacementEnabled Boolean Value Unchecked

// Function for creating TempDirectories
func createTempDirectory(folderName: String) -> String? {
    guard let tempDirURL = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(folderName) else {
        return nil
    }
    do {
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
        return nil
    }
    
    return (tempDirURL.path)
}

struct globalVariables {
    static var SelectedPkg = ""
    static var SelectedPkgFromFile = ""
    // Date right now
    static var DateNow = ""
    static var PkgsInfo:Array = [String]()
    static var PkgsFilesRaw:Array = [String]()
    static var PkgsFiles:Array = [String]()
    static var PkgsDirRaw:Array = [String]()
    static var PkgsDir:Array = [String]()
    static var PkgsDirFinal:Array = [String]()
    static var PkgsDirAndFilesRemove = Set([""])
    static var PkgsDirAndFilesRemoveRaw = Set([""])
    static var StatusCertificateCheckbox: Int = 0
    static var SelectedCertificate = ""
    static var Location = ""
    static var LocationRaw = ""
    static var Identifier = ""
    static var Version = ""
    static var IdentifierArray:Array = [String]()
    static var MainTempFolder = (createTempDirectory(folderName: "se.pkgscleaner")!)
    static var Signed = ""
    static var UnSigned = ""
    static var Output = ""
    // URL
    static var DocumentDirURL = URL(fileURLWithPath: "")
    // Tempfolders Variables
    static var TmpFolders = Set(["tmp","private","var"])
    // Variables PkgAndMpkg
    static var pkgsTemp = (createTempDirectory(folderName: "se.pkgscleaner/temp")!)
    static var DistroPKGS:Array = [String]()
    static var PkgsOrMpkg = ""
    static var PkgsOutput = ""
    static var PkgsOutputDirs = ""
    static var DirTemp:Array = [String]()
    static var FileTemp:Array = [String]()
    static var CleanRawArray: Set = ["","."]
}

// Clean Arrays using this Set, Its only Cleans exactly match, this paths wont get uninstalled
var CleanArray = Set(["","Applications","Applications/GRAPHISOFT","Applications/Graphisoft","Applications/Utilities","System", "System/Library","System/Library/Sandbox","System/Library/Extensions","System/Library/CoreServices","System/Library/LaunchAgents","System/Library/LaunchDaemons","System/Library/PrivateFrameworks","/System/Library/Video","/System/Library/Frameworks","Library","Library/Extensions","Library/LaunchAgents","Library/LaunchDaemons","Library/Application Support","Library/Application Support/Adobe","Adobe","Library/Documentation","Library/Documentation/Applications","Printers","Library/Frameworks","Library/Logs","Library/Java/JavaVirtualMachines","Library/Printers","Library/Printers/PPDs","Printers/PPDs","PPDs","PPDs/Contents","Printers/PPDs/Contents/Resources","Printers/PPDs/Contents","Library/Printers/RICOH/Profiles","Profiles","Library/Printers/RICOH/Icons","Icons","PPDs/Contents/Resources","Library/Printers/PPDs/Contents","Library/Printers/Sharp","Sharp","Printers/KONICAMINOLTA","Library/Printers/Sharp/PDEs","Library/Printers/Sharp/Icons","Library/Printers/Sharp/Filters","Sharp/PDEs","Sharp/Icons","Sharp/Filters","Library/Printers/PPDs/Contents/Resources","Library/Printers/toshiba","Library/Printers/hp","hp","Library/Printers/hp/Frameworks","hp/Frameworks","Library/Printers/hp/PDEs","Library/Printers/hp/Fax","Library/Printers/hp/filter","Library/Printers/hp/cups","Library/Printers/hp/cups/filters","Library/Printers/hp/Icons","Library/Printers/hp/Profiles","Library/Printers/hp/Utilities","Library/Printers/hp/Utilities/Handlers","Library/PrivilegedHelperTools","Library/Internet Plug-Ins","Library/ColorSync","Library/ColorSync/Profiles", "Library/PreferencePanes","Library/Java","Library/Java/Extensions","Application Support", "Library/Preferences","Library/Widgets","Library/Image Capture","Library/Image Capture/Devices","Application Support/KONICAMINOLTA","Library/Application Support/Adobe","Library/Application Support/Microsoft","Library/Application Support/Microsoft/Office365","Library/Application Support/Microsoft/Office365/User Content.localized","Library/Application Support/Microsoft/Office365/User Content.localized/Templates","Library/Caches", "LaunchAgents","LaunchDaemons","etc","etc/newsyslog.d","bin","usr","usr/standalone/firmware","usr/standalone/i386","usr/libexec/cups","usr/libexec/cups/backend","usr/bin","usr/lib","usr/libexec","usr/sbin","usr/share","usr/standalone","usr/share/man","usr/share/man/man1", "usr/local","usr/local/lib","usr/local/libexec","usr/local/bin","usr/local/sbin","usr/local/share","usr/local/share/doc","usr/local/share/man","opt","opt/local","sbin","private","private/etc","private/tmp","private/var", "private/etc/paths.d","private/var/db","private/var/db/dslocal","private/var/db/dslocal/nodes","private/var/db/dslocal/nodes/Default","private/var/db/dslocal/nodes/Default/users","Library/Application Support/com.apple.TCC", "Library/CoreAnalytics", "Library/Filesystems/NetFSPlugins/Staged", "Library/Filesystems/NetFSPlugins/Valid", "Library/Frameworks/iTunesLibrary.framework", "Library/GPUBundles", "Library/MessageTracer", "Library/Preferences/SystemConfiguration/com.apple.Boot.plist", "Library/StagedExtensions", "Library/Updates", "System", "System/Library/Assets", "System/Library/AssetsV2", "System/Library/Caches", "System/Library/Caches/com.apple.kext.caches", "System/Library/Extensions","System/Library/LaunchDaemons/com.apple.UpdateSettings.plist","System/Library/PreinstalledAssets", "System/Library/PreinstalledAssetsV2", "System/Library/User Template", "bin", "private/var/db/ConfigurationProfiles/Settings", "private/var/db/CVMS", "private/var/db/SystemPolicyConfiguration", "private/var/db/com.apple.xpc.roleaccountd.staging", "private/var/db/datadetectors", "private/var/db/dyld", "private/var/db/timezone","private/var/folders", "private/var/install", "sbin", "usr", "usr/libexec/cups", "usr/local", "usr/share/man", "usr/share/snmp", "etc", "tmp", "var"])

// Color for output text from Assets.xcassets
// https://developer.apple.com/documentation/appkit/supporting_dark_mode_in_your_interface
let colorText: [NSAttributedString.Key: Any] = [
    .foregroundColor: NSColor(named: NSColor.Name("ColorText"))!
]

let blackText: [NSAttributedString.Key: Any] = [
    .foregroundColor: NSColor(named: NSColor.Name("BlackText"))!
]

// Function for get right dateformat back to string
func dateToString(_ Date: Date) -> String? {
    let dateFormat = ISO8601DateFormatter()
    dateFormat.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    dateFormat.timeZone = TimeZone.current
    return dateFormat.string(from: Date)
}

