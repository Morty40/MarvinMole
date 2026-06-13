//
//  URL+DocumentsDirectory.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import Foundation

extension URL {
    
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask)[0]
    }
}
