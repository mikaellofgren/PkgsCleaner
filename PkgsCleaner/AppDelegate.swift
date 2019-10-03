//
//  AppDelegate.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-04-15.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var showTempfolder: NSMenuItem!
    @IBOutlet var pkgsPopup: NSPopUpButton!
    @IBOutlet var window: NSWindow!
    @IBOutlet var exportPopup: NSPopUpButton!
    @IBOutlet var finalOutPutTextField: NSTextView!
    @IBOutlet var openMenu: NSMenuItem!
    @IBOutlet var preferences: NSMenuItem!
    @IBOutlet var certificateCheckbox: NSButton!
    @IBOutlet var certificatePopup: NSPopUpButton!
    
 
 
    // START pkgDirOutputFunctionPrint
    func pkgDirOutputFunctionPrint () {
        if globalVariables.PkgsDirFinal.isEmpty == false {
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"DIR_PATHS=( ", attributes: blackText))
            for (idx, element) in globalVariables.PkgsDirFinal.enumerated() {
                if idx == globalVariables.PkgsDirFinal.endIndex-1 {
                    // For last element in array add a ) at the end of the output
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\" )\n", attributes: blackText))
                } else {
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\"\n", attributes: blackText))
                }
            }
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                
                for ALL in "${DIR_PATHS[@]}"; do
                if [ -d "$ALL" ]; then
                /bin/rm -rf "$ALL"
                fi
                done
                \n
                """, attributes: blackText))
        }
    }
    // END pkgDirOutputFunctionPrint
    
    // START pkgFilesOutputFunctionPrint
    func pkgFilesOutputFunctionPrint () {
        if globalVariables.PkgsFiles.isEmpty == false {
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"FILES_PATHS=( ", attributes: blackText))
            for (idx, element) in globalVariables.PkgsFiles.enumerated() {
                if idx == globalVariables.PkgsFiles.endIndex-1 {
                    // For last element in array add a ) at the end of the output
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\" )\n", attributes: blackText))
                } else {
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\"\n", attributes: blackText))
                }
            }
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                
                for ALL in "${FILES_PATHS[@]}"; do
                if [ -f "$ALL" ]; then
                /bin/rm "$ALL"
                fi
                done
                \n
                """, attributes: blackText))
        }
    }
    // END pkgFilesOutputFunctionPrint
    
    // START pkgutilForgetPrint
    func pkgutilForgetPrint () {
        finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
            /usr/sbin/pkgutil --forget \"\(globalVariables.SelectedPkg)\"\n
            exit 0\n
            """, attributes: blackText))
    }
    // END pkgutilForgetPrint
    
    // START RawDirOutputFunction
    func rawDirOutputFunction () {
        // Clean Arrays using globalVariables.PkgsDirAndFilesRemoveRaw remove empty value for nice output of Raw output
        // Raw Directories Output
        if globalVariables.PkgsDirRaw.isEmpty == false {
            // Remove empty values for nice output
            globalVariables.PkgsDirRaw.removeAll(where: { globalVariables.PkgsDirAndFilesRemoveRaw.contains($0) })
            // Insert like a header
            globalVariables.PkgsDirRaw.insert("# Raw Directories Output #", at: 0)
            // Insert linebreaks and bash comment #
            let pkgsDirRawWithSeparator = globalVariables.PkgsDirRaw.joined(separator: "\n# ")
            
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\(pkgsDirRawWithSeparator)", attributes: colorText))
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
            
        }
    }
    // END rawDirOutputFunction
    
    // START rawFilesOutputFunction
    func rawFilesOutputFunction () {
        // Raw Files Output
        if globalVariables.PkgsFilesRaw.isEmpty == false {
            // Remove empty values for nice output
            globalVariables.PkgsFilesRaw.removeAll(where: { globalVariables.PkgsDirAndFilesRemoveRaw.contains($0) })
            // Insert like a header
            globalVariables.PkgsFilesRaw.insert("# Raw Files Output #", at: 0)
            // Insert linebreaks and bash comment #
            let pkgsFilesRawWithSeparator = globalVariables.PkgsFilesRaw.joined(separator: "\n# ")
            
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\(pkgsFilesRawWithSeparator)", attributes: colorText))
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
        }
    }
    //END rawFilesOutputFunction
    
    
    @IBAction func pkgsPopUpSelected(_ sender: NSPopUpButtonCell) {
      
        // Pkg info /////////////////////////
        func pkginfoFunction () {
        let pkgInfoOutput = bash.execute(commandName: "/usr/sbin/pkgutil", arguments: ["--pkg-info",(globalVariables.SelectedPkg)])
        
        // Create a Array called globalVariables.PkgsInfo, where we store all output
        globalVariables.PkgsInfo = (pkgInfoOutput?.components(separatedBy: "\n"))!
        
            
        // Installation time from PkgsInfo (like bash date -r) Converted to day
            let InstallDateString = globalVariables.PkgsInfo[4].components(separatedBy: ":").last! as NSString
            let InstallDateDouble = InstallDateString.doubleValue
            let InstallDateFormat = Date(timeIntervalSince1970: InstallDateDouble )
           // Call function to convert to right Dateformat
            let InstallDate = dateToString(InstallDateFormat)!
        
        // Output Pkginfo
        finalOutPutTextField.textStorage?.append(NSAttributedString(string:"#!/bin/bash\n", attributes: blackText))
        finalOutPutTextField.textStorage?.append(NSAttributedString(string: """
            # Uninstall script created by PkgsCleaner \(globalVariables.DateNow)
            # \(globalVariables.PkgsInfo[0])
            # \(globalVariables.PkgsInfo[3])
            # \(globalVariables.PkgsInfo[1])
            # install-time: \(InstallDate)
            \n
            """, attributes: colorText))
        }
        
// END pkginfoFunction
        
        // START locationFunction
        func locationFunction () {
        // Get Locations path, clean empty space in beginning
        let locationSeparated = globalVariables.PkgsInfo[3].components(separatedBy: ":").last!
        globalVariables.Location = String(locationSeparated.dropFirst())
        
        // Get location path if empty just add a slash otherwise add slash at beginning and end
        if globalVariables.Location == "" {
            globalVariables.Location.insert("/", at: globalVariables.Location.startIndex)
        }
        
        // Check that Location starts with slash otherwise add it
        let LocationFirst = globalVariables.Location.first!
        if LocationFirst == "/" {
        }
        else {
            globalVariables.Location.insert("/", at: globalVariables.Location.startIndex)
        }
        
        // Check that Location ends with slash otherwise add it
        let LocationLast = globalVariables.Location.last!
        if LocationLast == "/" {
        }
        else {
            globalVariables.Location.insert("/", at: globalVariables.Location.endIndex)
        }
        }
        
        // END locationFunction
    

       
        
        // Start main script calling functions /////////////////////
        //SelectedPkg as String
        globalVariables.SelectedPkg = pkgsPopup.titleOfSelectedItem!
        
        // Remove Selected from file PKG from Popup everytime
        if globalVariables.SelectedPkgFromFile.isEmpty {
        } else {
            pkgsPopup.removeItem(withTitle: "\(globalVariables.SelectedPkgFromFile)" )
            globalVariables.SelectedPkgFromFile = ""
        }
        
        
        // Clear everything in finalOutPutTextField
        finalOutPutTextField.string = ""
        // If default is choosen dont do anything
        if globalVariables.SelectedPkg.contains("Please select a PKGs recipe"){
            // Dont do anything
            return
        }
        
        pkginfoFunction ()
        locationFunction ()
       
        // If Location contains tmp, private or var exit
        for all in globalVariables.TmpFolders {
            if globalVariables.Location.contains(all){
                //finalOutPutTextField.string += """
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"# This installer seems to install to a temp directory, check the installer scripts from original pkg.\n", attributes: colorText))
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                
                /usr/sbin/pkgutil --forget \"\(globalVariables.SelectedPkg)\"\n
                exit 0
                """, attributes: blackText))
                return }
        }

        
        pkgFilesFunction ()
        pkgDirFunction ()
       
        // If Pkgs is equal to tmp, var and private remove all
        if globalVariables.PkgsDir.isEmpty == false {
            for all in globalVariables.TmpFolders {
                if globalVariables.PkgsDir[0].contains(all){
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"# This installer seems to install to a temp directory, check the installer scripts from original pkg.\n", attributes: colorText))
                    finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                        
                        /usr/sbin/pkgutil --forget \"\(globalVariables.SelectedPkg)\"\n
                        exit 0
                        """, attributes: blackText))
                    return
                }
            }
            
        }
        
        
        // If PkgsDir and PkgsFiles is Empty the installer is probably a nopayload pkg installer
        if globalVariables.PkgsDir.isEmpty == true && globalVariables.PkgsFiles.isEmpty == true {
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"# This installer doesnt seems to install anything, probably a nopayload pkg, check the installer scripts from original pkg.\n", attributes: colorText))
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
            
            /usr/sbin/pkgutil --forget \"\(globalVariables.SelectedPkg)\"\n
            exit 0
            """, attributes: blackText))
            return
        }
        
        pkgDirOutputFunction ()
        pkgDirOutputFunctionPrint ()
        pkgFilesOutputFunction ()
        pkgFilesOutputFunctionPrint ()
        pkgutilForgetPrint ()
        rawDirOutputFunction ()
        rawFilesOutputFunction ()
        
    }
    
    @IBAction func openDialog(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles = true;
        dialog.allowedFileTypes = ["pkg", "mpkg"]

      if (dialog.runModal() == NSApplication.ModalResponse.OK) {
       let result = dialog.url // Pathname of the file
            if (result != nil) {
                let path = result!.path
                
                // Remove Selected PKG from files everytime
                if globalVariables.SelectedPkgFromFile.isEmpty {
                    globalVariables.DocumentDirURL = URL(fileURLWithPath: path)
                    let fileURL = globalVariables.DocumentDirURL
                    globalVariables.SelectedPkgFromFile = fileURL.lastPathComponent
                } else {
                    // Remove
                    pkgsPopup.removeItem(withTitle: "\(globalVariables.SelectedPkgFromFile)" )
                    // Generate new
                    globalVariables.DocumentDirURL = URL(fileURLWithPath: path)
                    let fileURL = globalVariables.DocumentDirURL
                    globalVariables.SelectedPkgFromFile = fileURL.lastPathComponent
                }
               dialog.close()
                
            }
        } else {
            print("Cancel")
            return
        }
        
        
        func printClassPackagesInfo(packagesinfo: [ClassPackagesInfo])
        {
            for pkgsNameEntry in packagesinfo {
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"# package-id: \(pkgsNameEntry.pkgsName)\n# location: \(pkgsNameEntry.pkgsInstallationPath)\n# version: \(pkgsNameEntry.pkgsVersion)\n", attributes: colorText))
            }
        }
        
        // START IdentifierArrayPrint
        func identifierArrayPrint () {
            if globalVariables.IdentifierArray.isEmpty == false {
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"PKGS=( ", attributes: blackText))
                for (idx, element) in globalVariables.IdentifierArray.enumerated() {
                    if idx == globalVariables.IdentifierArray.endIndex-1 {
                        // For last element in array add a ) at the end of the output
                        finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\" )\n", attributes: blackText))
                    } else {
                        finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\"\(element)\"\n", attributes: blackText))
                    }
                }
                finalOutPutTextField.textStorage?.append(NSAttributedString(string: """
                
                for ALL in "${PKGS[@]}"; do
                /usr/sbin/pkgutil --forget "$ALL"
                done\n
                exit 0\n
                """, attributes: blackText))
            }
        }
        // END IdentifierArrayPrint
        
        removeTempDir ()
        expandPKG ()
        // Create variable to get expandPKGchecker status
        var expandPKGsuccess:Bool
        expandPKGsuccess = expandPKGchecker()
        if expandPKGsuccess == true {
        pkgAndMpkg ()
        pkgDirOutputFunction ()
        pkgFilesOutputFunction()
        pkgsPopup.addItem(withTitle: "\(globalVariables.SelectedPkgFromFile)" )
        pkgsPopup.selectItem(withTitle: "\(globalVariables.SelectedPkgFromFile)")
        // Clear everything in finalOutPutTextField
        finalOutPutTextField.string = ""
        finalOutPutTextField.textStorage?.append(NSAttributedString(string: "#!/bin/bash\n", attributes: blackText))
        finalOutPutTextField.textStorage?.append(NSAttributedString(string: "# Uninstall script created by PkgsCleaner \(globalVariables.DateNow)\n", attributes: colorText))
        
      if globalVariables.PkgsFiles.isEmpty == true && globalVariables.PkgsDir.isEmpty == true {
            if globalVariables.PkgsOrMpkg == "Pkg" {
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                    # package-id: \(globalVariables.Identifier)
                    # location: \(globalVariables.Location)
                    # version: \(globalVariables.Version)\n
                    # This installer doesnt seems to install anything, probably a nopayload pkg.
                    # Check the installer scripts: \(globalVariables.pkgsTemp)/Scripts
                    \n
                    """, attributes: colorText))
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                    /usr/sbin/pkgutil --forget "\(globalVariables.Identifier)"\n
                    exit 0
                    """, attributes: blackText)) } else {
                printClassPackagesInfo(packagesinfo: packagesinfo)
                finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""

                                # This installer doesnt seems to install anything, probably a nopayload pkg. Check the installer scripts.
                                \n
                                """, attributes: colorText))
                identifierArrayPrint ()
                
            }
            return }
        
        
        if globalVariables.PkgsOrMpkg == "Pkg" {
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                # package-id: \(globalVariables.Identifier)
                # location: \(globalVariables.Location)
                # version: \(globalVariables.Version)\n
                
                """, attributes: colorText))
            pkgDirOutputFunctionPrint ()
            pkgFilesOutputFunctionPrint ()
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"""
                /usr/sbin/pkgutil --forget "\(globalVariables.Identifier)"\n
                exit 0
                
                """, attributes: blackText))
            rawDirOutputFunction ()
            rawFilesOutputFunction ()
        } else {
            printClassPackagesInfo(packagesinfo: packagesinfo)
            finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
            pkgDirOutputFunctionPrint ()
            pkgFilesOutputFunctionPrint ()
            identifierArrayPrint ()
            rawDirOutputFunction ()
            rawFilesOutputFunction ()
        }
        finalOutPutTextField.textStorage?.append(NSAttributedString(string:"\n", attributes: colorText))
        
        } else {
            // Reset pkgsPopup and SelectedPkgFromfile and Clear Textfield
            pkgsPopup.selectItem(at: 0)
            globalVariables.SelectedPkgFromFile.removeAll()
            finalOutPutTextField.string = ""
            
            // Show warning
             let fileURL = globalVariables.DocumentDirURL.path
            let warning = NSAlert()
            warning.messageText = "Expand pkg file failed"
            warning.informativeText = """
            Try to expand manually with this command in terminal:
            /usr/sbin/pkgutil --expand "\(fileURL)" "\(fileURL)expanded"
            """
            warning.runModal()
           
            
            return
        }
    }
    
    
    

    @IBAction func ExportNopayload(_ sender: Any) {
        // If globalVariables.SelectedPkgFromFile is not empty change it to globalVariables.SelectedPkg
        // so it works with export options
        if globalVariables.SelectedPkgFromFile.isEmpty {
        } else {
            globalVariables.SelectedPkg = globalVariables.SelectedPkgFromFile
        }
        
        // If default is choosen dont do anything
        if globalVariables.SelectedPkg.contains("Please select a PKGs recipe"){
            // Dont do anything and reset Export as option
            exportPopup.selectItem(at: 0)
            return
        }
        
        
        
        // Save Dialog
        let dialog = NSSavePanel();
        dialog.message = "Select location for output";
        dialog.showsTagField = false;
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
      
        
        
        // Default Save value, add .pkg or not
        let endsWithPkg = globalVariables.SelectedPkg.suffix(4)
        if endsWithPkg == ".pkg" {
            dialog.nameFieldStringValue = "Uninstaller_\(globalVariables.SelectedPkg)";
        } else {
            dialog.nameFieldStringValue = "Uninstaller_\(globalVariables.SelectedPkg).pkg";
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                let path = result!.path
                
                
                // Call function for creating tempdirectories
                let scriptsFolder = (createTempDirectory(folderName: "se.pkgscleaner/scripts")!)
                let nopayloadFolder = (createTempDirectory(folderName: "se.pkgscleaner/nopayload")!)
                
                // Convert scriptsFolder to URL
                let DocumentDirURL = URL(fileURLWithPath: scriptsFolder)
                
                
                // Get the text in textview to output to a tmp file for calling from pkgsbuild
                // Save data to file
                let fileName = "postinstall"
                let fileURL = DocumentDirURL.appendingPathComponent(fileName)
                let writeString = (finalOutPutTextField.textStorage as NSAttributedString?)!.string
                do {
                    // Write to the file
                    try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                }
                
                // Remove Extended attributs and Chmod on tempfile
                _ =  bash.execute(commandName: "/usr/bin/xattr", arguments: ["-c","\(fileURL.path)"])
                _ = bash.execute(commandName: "/bin/chmod", arguments: ["a+x","\(fileURL.path)"])
                
            // Output Signed pkg
                if globalVariables.StatusCertificateCheckbox == 1 {
                    globalVariables.SelectedCertificate = certificatePopup.titleOfSelectedItem!


                // Output variables for root and scriptsfolders needs to be like "/Users/username/Desktop/" "--version","1.0"
                // If no Version is added then no pkginfo is written to package database
                    globalVariables.Signed = bash.execute(commandName: "/usr/bin/pkgbuild", arguments:  ["--sign","\(globalVariables.SelectedCertificate)","--identifier","se.pkgscleaner","--root","\(nopayloadFolder)","--scripts","\(scriptsFolder)","\(path)"])!
                    
                    globalVariables.Output = globalVariables.Signed as String
                } else {
                     // Output UnSigned pkg
                   
                    globalVariables.UnSigned = bash.execute(commandName: "/usr/bin/pkgbuild", arguments: ["--identifier","se.pkgscleaner","--root","\(nopayloadFolder)","--scripts","\(scriptsFolder)","\(path)"])!
                    
                     globalVariables.Output = globalVariables.UnSigned as String
                }
                if globalVariables.Output.contains("Wrote") {
                    
                    // Create the notification and setup information (depricated should be updated)
                    let notification = NSUserNotification()
                    notification.identifier = "se.dicom.pkgscleaner"
                    notification.title = "Successfully exported to:"
                    notification.subtitle = "\(path)"
                    notification.soundName = NSUserNotificationDefaultSoundName
                    let notificationCenter = NSUserNotificationCenter.default
                    notificationCenter.deliver(notification)
                    
                    let warning = NSAlert()
                    warning.addButton(withTitle: "OK")
                    warning.alertStyle = NSAlert.Style.informational
                    warning.messageText = "Successfully exported to"
                    warning.informativeText = "\(path)"
                    warning.runModal()
                    
                   // Reset Export as option
                    exportPopup.selectItem(at: 0)
                } else {
               
                    let warning = NSAlert()
                    warning.icon = NSImage(named: "Warning")
                    warning.addButton(withTitle: "OK")
                    warning.messageText = "Something went wrong"
                    warning.alertStyle = NSAlert.Style.warning
                    // Show warning dialog with differents output depending if signed or not
                    if globalVariables.StatusCertificateCheckbox == 1 {
                    warning.informativeText = """
Before you quit the app, try it manually by copy this command into terminal:

/usr/bin/pkgbuild --sign \"\(globalVariables.SelectedCertificate)\" --identifier se.pkgscleaner --root \(nopayloadFolder) --scripts \(scriptsFolder) \(path)
"""
                     } else {
                    warning.informativeText = """
Before you quit the app, try it manually by copy this command into terminal:

/usr/bin/pkgbuild --identifier se.pkgscleaner --root \(nopayloadFolder) --scripts \(scriptsFolder) \(path)
"""
                        }
                   
                    warning.runModal()
                    
                    // Reset Export as option
                    exportPopup.selectItem(at: 0)
                }
            }
        } else {
            // User clicked on "Cancel"
            // Dont do anything and reset Export as option
            exportPopup.selectItem(at: 0)
            return
        }
        // End Save Dialog
       
    }
    
    
    
    @IBAction func ExportScript(_ sender: Any) {
        // If globalVariables.SelectedPkgFromFile is not empty change it to globalVariables.SelectedPkg
        // so it works with export options
        if globalVariables.SelectedPkgFromFile.isEmpty {
        } else {
            globalVariables.SelectedPkg = globalVariables.SelectedPkgFromFile
        }
        
        // If default is choosen dont do anything
        if globalVariables.SelectedPkg.contains("Please select a PKGs recipe"){
            // Dont do anything and reset Export as option
            exportPopup.selectItem(at: 0)
            return
        }
        // Save Dialog
        let dialog = NSSavePanel();
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
    
        
       // Default Save value, add .sh and remove .pkg
        let endsWithPkg = globalVariables.SelectedPkg.suffix(4)
        if endsWithPkg == ".pkg" {
            dialog.nameFieldStringValue = "Uninstaller_\(globalVariables.SelectedPkg.dropLast(4)).sh";
        } else {
            dialog.nameFieldStringValue = "Uninstaller_\(globalVariables.SelectedPkg).sh";
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                let path = result!.path
                
                 let documentDirURL = URL(fileURLWithPath: path)
                // Save data to file
                let fileURL = documentDirURL
                let writeString = (finalOutPutTextField.textStorage as NSAttributedString?)!.string
                do {
                    // Write to the file
                    try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                }
                
                // Remove Extended attributs and Chmod on tempfile
                _ =  bash.execute(commandName: "/usr/bin/xattr", arguments: ["-c","\(fileURL.path)"])
                _ = bash.execute(commandName: "/bin/chmod", arguments: ["a+x","\(fileURL.path)"])
                
                // Reset Export as option
                exportPopup.selectItem(at: 0)
                
                // Create the notification and setup information (depricated should be updated)
                let notification = NSUserNotification()
                notification.identifier = "se.dicom.pkgscleaner"
                notification.title = "Succesfully exported to:"
                notification.subtitle = "\(path)"
                notification.soundName = NSUserNotificationDefaultSoundName
                let notificationCenter = NSUserNotificationCenter.default
                notificationCenter.deliver(notification)
            }
        } else {
            // User clicked on "Cancel"
            // Dont do anything and reset Export as option
            exportPopup.selectItem(at: 0)
            return
        }
        // End Save Dialog
        
        
        
        
        
    }


    
    
    @IBAction func shellSheck(sender: AnyObject) {
       if globalVariables.SelectedPkgFromFile.isEmpty {
        } else {
            globalVariables.SelectedPkg = globalVariables.SelectedPkgFromFile
        }
         // If default is choosen dont do anything
                if globalVariables.SelectedPkg.contains("Please select a PKGs recipe"){
                    return
                }
        
        // Copy finalOutPutTextField to pasteboard and open Shellcheck.net
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        let writeString = (finalOutPutTextField.textStorage as NSAttributedString?)!.string
        pasteBoard.writeObjects([writeString as NSPasteboardWriting])
        
        let url = URL(string: "https:/www.shellcheck.net")!
        if NSWorkspace.shared.open(url) {
        }

    }
    

    @IBAction func CertificateButtom(_ sender: NSButton) {

     func CreateCertificatePopup() {
                    let myIdentities = getAllKeyChainIdentityItems()
                    var developerIdentities:Array = [String]()
                    for items in myIdentities {
                        let lastItems = items.components(separatedBy: ":").last!
                        let lastItemsClean = String(lastItems.dropFirst())
                        developerIdentities.append(lastItemsClean)
                    }
        
        
                     if developerIdentities.isEmpty == false {
                        certificatePopup.isEnabled = true
                        certificatePopup.removeAllItems()
                    // Add an item to the list
                        certificatePopup.addItems(withTitles: developerIdentities)
                        certificatePopup.selectItem(at: 0)
                     } else {
                        // If no certificate is found Checkbox to Off and variable to 0
                        certificatePopup.addItems(withTitles: ["No Developer Certificates found"])
                        // Set the state to Off
                        certificateCheckbox.state = NSControl.StateValue.off
                          globalVariables.StatusCertificateCheckbox = 0
        
        
                    }
        
                }
        
        
    globalVariables.StatusCertificateCheckbox = sender.state.rawValue
        certificatePopup.removeAllItems()
        
                // If Checkbox is ON (1) try get Certificates
                if globalVariables.StatusCertificateCheckbox == 1 {
                    CreateCertificatePopup()
                    globalVariables.SelectedCertificate = certificatePopup.titleOfSelectedItem!
                } else {
                    // Set the state to Off
                    certificateCheckbox.state = NSControl.StateValue.off
                    globalVariables.StatusCertificateCheckbox = 0
                }
 }
    

    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // List all PKGS
        var pkgsOutput = bash.execute(commandName: "/usr/sbin/pkgutil", arguments: ["--pkgs"])
        
        // Create a Array called PkgsTemp, where we store all output
        var pkgsTemp:Array = (pkgsOutput?.components(separatedBy: "\n"))!
        
        // Remove com.apple pkgs cause we dont want to uninstall Apple systemfiles, and they are sometimes to complex to parse
        var pkgs:Array = [String]()
        for elements in pkgsTemp {
            // Remove items contains com.apple
            pkgs.append(elements.deletingPrefix("com.apple"))
        }
        
         // Clean Array using this Set
        let cleanPkgsArray: Set = [""]
       pkgs.removeAll(where: { cleanPkgsArray.contains($0) })
       
        // Sort Pkgs Array
        pkgs.sort()
        
        // Create PkgsPopup
        func createPkgsPopup() {
            pkgsPopup.removeAllItems()
            // Add an item to the list
            pkgsPopup.addItem(withTitle: "Please select a PKGs recipe [ of total \(pkgs.count) ]")
            pkgsPopup.addItems(withTitles: pkgs)
            pkgsPopup.selectItem(at: 0)
            globalVariables.SelectedPkg = pkgsPopup.titleOfSelectedItem!
            
        }
        
        createPkgsPopup()
        

        // Get date
        globalVariables.DateNow = dateToString(Date())!
     
    }
    
    @IBAction func showTempfolders(_ sender: Any) {
        // Create and open the temp folder in Finder
        _ = globalVariables.pkgsTemp
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "\(globalVariables.pkgsTemp)")
    }
    

    
    func applicationWillTerminate(_ aNotification: Notification) {
 }
 
    @IBAction func myQuitButtom(_ sender: NSButton) {
        // Delete tempfolder if exist
        if FileManager.default.fileExists(atPath: globalVariables.MainTempFolder) {
        // Delete folder
        try? FileManager.default.removeItem(atPath: globalVariables.MainTempFolder)
        }
        exit(0);
    }
    
}

