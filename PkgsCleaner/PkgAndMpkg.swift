//
//  PkgAndMpkg.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-08-03.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//


import Foundation


// START removeTempDir
func removeTempDir () {
if FileManager.default.fileExists(atPath: globalVariables.pkgsTemp) {
    // Delete folder
    try? FileManager.default.removeItem(atPath: globalVariables.pkgsTemp)
}
}
// END removeTempDir

// START expandPKG
func expandPKG() {
    // Get fileURL in this format /Users/username/Desktop/nameOfPkg.pkg
    let fileURL = globalVariables.DocumentDirURL.path
    _ = bash.execute(commandName: "/usr/sbin/pkgutil", arguments: ["--expand","\(fileURL)","\(globalVariables.pkgsTemp)"])
}
// END expandPKG

// START expandPKGchecker, return true if exist else false
func expandPKGchecker() -> Bool {
    if FileManager.default.fileExists(atPath: globalVariables.pkgsTemp) {
        return true
    } else {
        return false
    }
}
// END expandPKGchecker



// START Class for PackagesInfo
class ClassPackagesInfo {
    let pkgsName : String
    let pkgsInstallationPath : String
    let pkgsVersion : String
    
    init(pkgsName: String, pkgsInstallationPath: String, pkgsVersion : String) {
        self.pkgsName = pkgsName
        self.pkgsInstallationPath = pkgsInstallationPath
        self.pkgsVersion = pkgsVersion
    }
}

var packagesinfo:[ClassPackagesInfo] = []
// END Class for PackagesInfo

// START locationCheckerFunction
func locationCheckerFunction () {
    
    // Get location path if empty just add a slash otherwise add slash at beginning and end
    if globalVariables.Location == "" {
        globalVariables.Location.insert("/", at: globalVariables.Location.startIndex)
    }
    
    // Check that Location starts with slash otherwise add it
    let locationFirst = globalVariables.Location.first!
    if locationFirst == "/" {
    }
    else {
        globalVariables.Location.insert("/", at: globalVariables.Location.startIndex)
    }
    
    // Check that Location ends with slash otherwise add it
    let locationLast = globalVariables.Location.last!
    if locationLast == "/" {
    }
    else {
        globalVariables.Location.insert("/", at: globalVariables.Location.endIndex)
    }
    for all in globalVariables.TmpFolders {
        if globalVariables.Location.contains(all){
            globalVariables.Location = "tmp"
            return
        }
    }
}
// END LocationCheckerFunction



// START PkgAndMpkg
func pkgAndMpkg () {
    
    // If distribution file exist, grep all pkgs references from distribution file using "function pkgref"
    // add results to DistroPKGS array, use that to grep file and folders info from Bom files.
    
    // Clear arrays before we start
    globalVariables.PkgsFiles = [String]()
    globalVariables.PkgsDir = [String]()
    globalVariables.PkgsFilesRaw = [String]()
    globalVariables.PkgsDirRaw = [String]()
    globalVariables.IdentifierArray = [String]()
    packagesinfo.removeAll()
    
    let fileManager = FileManager.default
    // Set the file path
    let FilePath = "\(globalVariables.pkgsTemp)/Distribution"
    
pkgFilesDirs: if fileManager.fileExists(atPath: "\(globalVariables.pkgsTemp)/Distribution") {
    globalVariables.PkgsOrMpkg = "Mpkg"
    print("Mpkg format")
    
    // Get the Contents
    do {
    let FileContents = try String(contentsOfFile: FilePath, encoding: .utf8)
        // Create array from every pkgref from Distributionfile
        globalVariables.DistroPKGS = FileContents.pkgref()
       
    } catch {
        //handle error
        print(error)
        return
    }
    
    
    
    // If Distropkgs refs filepath includes %20 for spaces in filepath remove the Percent Encoding
    for elements in globalVariables.DistroPKGS {
        // Empty Strings before we start
        globalVariables.Identifier.removeAll()
        globalVariables.Location.removeAll()
        globalVariables.Version.removeAll()
        globalVariables.LocationRaw.removeAll()
      
        let filePathLocation = "\(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/PackageInfo"
         do {
        let fileContents = try String(contentsOfFile: filePathLocation, encoding: .utf8)
            
             // Get identifier and version and location
            if fileContents.identifier().isEmpty {
            } else {
                 globalVariables.Identifier = fileContents.identifier()[0].replacingOccurrences(of: "identifier=", with: "")
                // Add globalVariables.Identifier to an array to use for multiple output later on
                globalVariables.IdentifierArray.append(globalVariables.Identifier)
            }
           
            if fileContents.version().isEmpty {
            } else {
            globalVariables.Version = fileContents.version()[0].replacingOccurrences(of: " version=", with: "")
            }
            
            if fileContents.installLocation().isEmpty {
                globalVariables.Location = "/"
            } else {
                globalVariables.Location = fileContents.installLocation()[0].replacingOccurrences(of: "install-location=", with: "") as String
                }
            
            // Make a new LocationVariable from raw value to use to inform if files installs to tmp folders
            globalVariables.LocationRaw = globalVariables.Location
            locationCheckerFunction ()
            
         } catch {
            //handle error
            print(error)
        }
        
        
        if fileManager.fileExists(atPath: "\(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/Bom") {
            // List PkgsFiles
            globalVariables.PkgsOutput = bash.execute(commandName: "/usr/bin/lsbom", arguments: ["-f","-s","\(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/Bom"])!
            
            // List PkgsDir
            globalVariables.PkgsOutputDirs = bash.execute(commandName: "/usr/bin/lsbom", arguments: ["-d","-s","\(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/Bom"])!
            
            // Add output to two arrays
            globalVariables.FileTemp = (globalVariables.PkgsOutput.components(separatedBy: "\n"))
            globalVariables.DirTemp = (globalVariables.PkgsOutputDirs.components(separatedBy: "\n"))
            
            // Make a copy for RAW output
            globalVariables.PkgsFilesRaw += globalVariables.FileTemp
            globalVariables.PkgsDirRaw += globalVariables.DirTemp
            
            // Clean Raw arrays from . and empty
            globalVariables.PkgsFilesRaw.removeAll(where: { globalVariables.CleanRawArray.contains($0) })
            globalVariables.PkgsDirRaw.removeAll(where: { globalVariables.CleanRawArray.contains($0) })
            
            // Remove two first characthers ./
            globalVariables.FileTemp = globalVariables.FileTemp.map({ String($0.dropFirst(2)) })
            globalVariables.DirTemp = globalVariables.DirTemp.map({ String($0.dropFirst(2)) })
            
            // Clean temp arrays
            globalVariables.FileTemp.removeAll(where: { CleanArray.contains($0) })
            globalVariables.DirTemp.removeAll(where: { CleanArray.contains($0) })
            
            
           
            // If Location contains tmp skip files, but inform in output comments
            if globalVariables.Location == "tmp" {
                let tempPkgsinfo = ClassPackagesInfo(pkgsName: "\(globalVariables.Identifier)", pkgsInstallationPath: "\(globalVariables.LocationRaw)\n# Installs to a temp folder, check installerscripts: \(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/Scripts", pkgsVersion: "\(globalVariables.Version)")
                packagesinfo.append(tempPkgsinfo)
            } else {
                // Add Location before files and Dirs
                globalVariables.PkgsFiles += globalVariables.FileTemp.map({ globalVariables.Location + $0 })
                globalVariables.PkgsDir += globalVariables.DirTemp.map({ globalVariables.Location + $0 })
                let tempPkgsinfo = ClassPackagesInfo(pkgsName: "\(globalVariables.Identifier)", pkgsInstallationPath: globalVariables.LocationRaw, pkgsVersion: "\(globalVariables.Version)")
                packagesinfo.append(tempPkgsinfo)
            }
            
            
            // And when we are done, empty temp arrays
            globalVariables.FileTemp.removeAll()
            globalVariables.DirTemp.removeAll()
            
        }
        else { print("We got a nopayload package")
                if globalVariables.Location == "tmp" {
                    let tempPkgsinfo = ClassPackagesInfo(pkgsName: "\(globalVariables.Identifier)", pkgsInstallationPath: "\(globalVariables.LocationRaw)\n# Installs to a temp folder, check installerscripts: \(globalVariables.pkgsTemp)/\(elements.removingPercentEncoding!)/Scripts", pkgsVersion: "\(globalVariables.Version)")
                    packagesinfo.append(tempPkgsinfo)
                }

           break pkgFilesDirs
        }
    }
    
} else {
    globalVariables.PkgsOrMpkg = "Pkg"
    print("Pkg format")
    
    // Empty Strings before we start
    globalVariables.Identifier.removeAll()
    globalVariables.Location.removeAll()
    
    let filePathLocation = "\(globalVariables.pkgsTemp)/PackageInfo"
     do {
        // Get identifier and version and location
    let fileContents = try String(contentsOfFile: filePathLocation, encoding: .utf8)
        
        if fileContents.identifier().isEmpty {
        } else {
            globalVariables.Identifier = fileContents.identifier()[0].replacingOccurrences(of: "identifier=", with: "")
            // Add globalVariables.Identifier only to an array to use for output later on
            globalVariables.IdentifierArray.append(globalVariables.Identifier)
        }
        
        if fileContents.version().isEmpty {
        } else {
            globalVariables.Version = fileContents.version()[0].replacingOccurrences(of: " version=", with: "")
        }
        
        if fileContents.installLocation().isEmpty {
            globalVariables.Location = "/"
        } else {
            globalVariables.Location = fileContents.installLocation()[0].replacingOccurrences(of: "install-location=", with: "") as String
        }
   
        locationCheckerFunction ()
    
     } catch {
        //handle error
        print(error)
    }
    
    
    if fileManager.fileExists(atPath: "\(globalVariables.pkgsTemp)/Bom") {
        globalVariables.PkgsOutput = bash.execute(commandName: "/usr/bin/lsbom", arguments: ["-f","-s","\(globalVariables.pkgsTemp)/Bom"])!
        globalVariables.PkgsOutputDirs = bash.execute(commandName: "/usr/bin/lsbom", arguments: ["-d","-s","\(globalVariables.pkgsTemp)/Bom"])!
        
        // Add output to two arrays
        globalVariables.FileTemp = (globalVariables.PkgsOutput.components(separatedBy: "\n"))
        globalVariables.DirTemp = (globalVariables.PkgsOutputDirs.components(separatedBy: "\n"))
        
        // Make a copy for RAW output
        globalVariables.PkgsFilesRaw += globalVariables.FileTemp
        globalVariables.PkgsDirRaw += globalVariables.DirTemp
        
        // Clean Raw arrays from only dots . and empty
        globalVariables.PkgsFilesRaw.removeAll(where: { globalVariables.CleanRawArray.contains($0) })
        globalVariables.PkgsDirRaw.removeAll(where: { globalVariables.CleanRawArray.contains($0) })
        
        // Remove two first characthers ./
        globalVariables.FileTemp = globalVariables.FileTemp.map({ String($0.dropFirst(2)) })
        globalVariables.DirTemp = globalVariables.DirTemp.map({ String($0.dropFirst(2)) })
        
        // Clean temp arrays
        globalVariables.FileTemp.removeAll(where: { CleanArray.contains($0) })
        globalVariables.DirTemp.removeAll(where: { CleanArray.contains($0) })
        
        // Add Location to a new array
        globalVariables.PkgsFiles += globalVariables.FileTemp.map({ globalVariables.Location + $0 })
        globalVariables.PkgsDir += globalVariables.DirTemp.map({ globalVariables.Location + $0 })
        
        // When we are done, empty temp arrays
        globalVariables.FileTemp.removeAll()
        globalVariables.DirTemp.removeAll()
        
    } else {
        break pkgFilesDirs
    }
}

// Call funtion to sort by length
globalVariables.PkgsDir.sort(by: length)

}
// END pkgAndMpkg
