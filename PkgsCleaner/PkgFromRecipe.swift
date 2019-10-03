//
//  PkgFromPkgRecipe.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-08-04.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//

import Foundation



// START pkgFilesFunction
func pkgFilesFunction () {
    
    let pkgsOutputOnlyFiles = bash.execute(commandName: "/usr/sbin/pkgutil", arguments: ["--only-files","--files",(globalVariables.SelectedPkg)])
    
    //Create Array PkgsFiles
    globalVariables.PkgsFiles = (pkgsOutputOnlyFiles?.components(separatedBy: "\n"))!
    
    //Create Array thats a copy of PkgsFiles use for RAW output
    globalVariables.PkgsFilesRaw = globalVariables.PkgsFiles
    
    
    // Add globalVariables.Location to a every elements in globalVariables.PkgsFiles using .map
    // Clean using set CleanArray but not for suffix .app
    if globalVariables.Location.suffix(5) == ".app/" {
        globalVariables.PkgsFiles = globalVariables.PkgsFiles.map({ globalVariables.Location + $0 })
    } else {
        //// Clean Array
        globalVariables.PkgsFiles.removeAll(where: { CleanArray.contains($0) })
        globalVariables.PkgsFiles = globalVariables.PkgsFiles.map({ globalVariables.Location + $0 })
    }
    
}
// END pkgFilesFunction




// START pkgDirFunction
func pkgDirFunction () {
    
    let pkgsOutputOnlyDir = bash.execute(commandName: "/usr/sbin/pkgutil", arguments: ["--only-dirs","--files",(globalVariables.SelectedPkg)])
    
    
    // Create a Arry called PkgsDir, where we store all output
    globalVariables.PkgsDir = (pkgsOutputOnlyDir?.components(separatedBy: "\n"))!
    
    //Create Array thats a copy of PkgsDir use for RAW output
    globalVariables.PkgsDirRaw = globalVariables.PkgsDir
    
    // Add globalVariables.Location to a every elements in globalVariables.PkgsDir using .map
    // Clean using set CleanArray but not for suffix .app or .plugin
    if globalVariables.Location.suffix(5) == ".app/" || globalVariables.Location.suffix(8) == ".plugin/" {
        globalVariables.PkgsDir = globalVariables.PkgsDir.map({ globalVariables.Location + $0 })
    } else {
        // Clean Array
        globalVariables.PkgsDir.removeAll(where: { CleanArray.contains($0) })
        globalVariables.PkgsDir = globalVariables.PkgsDir.map({ globalVariables.Location + $0 })
    }
    
    // Call funtion and sort by length
    globalVariables.PkgsDir.sort(by: length)
}
// END pkgDirFunction


// START pkgDirOutputFunction
func pkgDirOutputFunction () {
    var firstPkgsDir = ""
    
    
    // Empty Array globalVariables.PkgsDirFinal where we store final output from Directories
    globalVariables.PkgsDirFinal = [String]()
    globalVariables.PkgsDirAndFilesRemove.removeAll()
    
    // Get first/shortest elements from PkgsDir
    // add that to a new array and a variable FirstPkgsDir
    // Repeat for all elements in PkgsDir until its empty
    // Using PkgsDirAndFilesRemove array for the removing
    if globalVariables.PkgsDir.isEmpty == false {
        repeat {
            firstPkgsDir = globalVariables.PkgsDir[0]
            globalVariables.PkgsDirFinal.append(firstPkgsDir)
            for elements in globalVariables.PkgsDir {
                if elements.contains(firstPkgsDir) {
                    globalVariables.PkgsDirAndFilesRemove.insert(elements)
                }
            }
            globalVariables.PkgsDir.removeAll(where: { globalVariables.PkgsDirAndFilesRemove.contains($0) })
        } while (globalVariables.PkgsDir.isEmpty == false)
}
}
// END pkgDirOutputFunction

// START pkgFilesOutputFunction
func pkgFilesOutputFunction () {
    // Output Pkgsfiles START, clean Files array using globalVariables.PkgsDirAndFilesRemove
    if globalVariables.PkgsDirFinal.isEmpty == false {
        for all in globalVariables.PkgsDirFinal {
            for elements in globalVariables.PkgsFiles {
                if elements.contains(all) {
                    globalVariables.PkgsDirAndFilesRemove.insert(elements)
                    
                }
            }
        }
        globalVariables.PkgsFiles.removeAll(where: { globalVariables.PkgsDirAndFilesRemove.contains($0) })
    }
}
// END pkgFilesOutputFunction
