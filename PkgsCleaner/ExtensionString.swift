//
//  ExtensionString.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-04-19.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//

import Foundation
// https://stackoverflow.com/questions/28323848/removing-from-array-during-enumeration-in-swift


// Deleting Prefix from Array strings
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
         return String()
    }
}


// Function to Sort Arrays by length
        func length(value1: String, value2: String) -> Bool {
            // Compare character count of the strings.
            return value1.count < value2.count
        }


// Get Pkgs name from Distribution file
extension String
{
    func pkgref() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "#.+\\.pkg", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "")
            }
        }
        
        return []
    }
}

// Get Install Location from PackageInfo file
extension String
{
    func installLocation() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "install-location=(\"([^\"]|\"\")*\")", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "\"", with: "")
            }
        }
        
        return []
    }
}

// Get Identifier from PackageInfo file
extension String
{
    func identifier() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "identifier=(\"([^\"]|\"\")*\")", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "\"", with: "")
            }
        }
        
        return []
    }
}

// Get Version from PackageInfo file
extension String
{
    func version() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "\" version=(\"([^\"]|\"\")*\")", options: .caseInsensitive)
            {
            let string = self as NSString
             
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "\"", with: "")
            }
        }
       
        return []
        
    }
}


