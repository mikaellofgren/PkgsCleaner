//
//  Keychain.swift
//  PkgsCleaner
//
//  Created by Mikael Löfgren on 2019-07-15.
//  Copyright © 2019 Mikael Löfgren. All rights reserved.
//

import Foundation
public func getAllKeyChainIdentityItems() -> [String] {
    
    let query: [String: Any] = [
        kSecClass as String : kSecClassIdentity,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecReturnAttributes as String : kCFBooleanTrue!,
        kSecReturnRef as String : kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitAll
    ]
    
    var result: AnyObject?
    
    let lastResultCode = withUnsafeMutablePointer(to: &result) {
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    var values = [String]()
    
    if lastResultCode == noErr {
        let array = result as? Array<Dictionary<String, Any>>
        
        for item in array! {
            let label = item[kSecAttrLabel as String] as? String
            if label!.contains("Developer") {
                values.append(label!)
                
            }
            
        }
    }
    
    return values
}

