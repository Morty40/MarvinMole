//
//  URL+DocumentsDirectory.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

extension URL {
    
    /// (for iOS 15 support)
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask)[0]
    }
}
