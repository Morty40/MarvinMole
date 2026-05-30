//
//  SKTexture+Split.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

extension SKTexture {
    
    /// Split a texture (e.g. sprite sheet) into multiple textures, by columns and rows.
    /// When columns and rows are zero, attempt to calculate the number of splits.
    /// - Parameters:
    ///   - columns: Number of columns
    ///   - rows: Number of rows
    /// - Returns: Array of textures
    func split(columns: Int = 0, rows: Int = 0) -> [SKTexture] {
        var textures: [SKTexture] = []

        let s = size()
        let minLength = min(s.width, s.height)
        let maxLength = max(s.width, s.height)
        let n = Int(maxLength / minLength)
        let c = columns == 0 ? (s.width > s.height ? n : 1) : columns
        let r = rows == 0 ? (s.width < s.height ? n : 1) : rows

        for y in 0 ..< r {
            for x in 0 ..< c {
                let rect = CGRect(x: CGFloat(x) / CGFloat(c),
                                  y: CGFloat(r-y-1) / CGFloat(r),
                                  width: 1.0 / CGFloat(c),
                                  height: 1.0 / CGFloat(r))
                textures.append(SKTexture(rect: rect, in: self))
            }
        }
        
        return textures
    }
    
}
