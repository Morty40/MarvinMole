//
//  Object.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

/// Object base class
class Object: SKSpriteNode {
    
    var id: Int = 0
    
    func setMapPosition(x: Int, y: Int, tileMap: TileMap) {
        let w = tileMap.frame.width / tileMap.xScale
        let h = tileMap.frame.height / tileMap.yScale
        
        position = CGPoint(x: 32*(CGFloat(x)+0.5) - w/2,
                           y: h/2 - 32*(CGFloat(y)+0.5))
    }
    
    init() {
        let texture = SKTexture(imageNamed: "HeroWalkLeft")
        super.init(texture: texture, color: .red, size: CGSize(width: 32, height: 32))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let shadowTexture = SKTexture(imageNamed: "ObjectShadow")
        let shadow = SKSpriteNode(texture: shadowTexture, size: CGSize(width: 48, height: 16))
        shadow.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shadow.position = CGPoint(x: 0, y: -16)
        shadow.zPosition = -1
        shadow.alpha = 0.3
        self.addChild(shadow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
