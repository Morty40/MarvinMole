//
//  SKTexture+Split.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

extension SKTexture {
    
    /// Split a texture (e.g. sprite sheet) into multiple textures, by columns x rows
    /// - Parameters:
    ///   - columns: Number of columns
    ///   - rows: Number of rows
    /// - Returns: Array of textures
    func split(columns: Int = 1, rows: Int = 1) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for y in 0 ..< rows {
            for x in 0 ..< columns {
                let rect = CGRect(x: CGFloat(x) / CGFloat(columns),
                                  y: CGFloat(y) / CGFloat(rows),
                                  width: 1.0 / CGFloat(columns),
                                  height: 1.0 / CGFloat(rows))
                textures.append(SKTexture(rect: rect, in: self))
            }
        }
        
        return textures
    }
}
