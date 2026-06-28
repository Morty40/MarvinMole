//
//  FloodScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class FloodScene: Scene {
    
    private var map: Map = .empty
    
    private var sfx = SKAction.playSoundFileNamed("WaterFlooding.wav", waitForCompletion: false)

    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "GameBackground")
        node.position = center
        node.size = size
        return node
    }()
    
    private lazy var mapView = {
        let node = MapView()
        node.position = center
        return node
    }()
    
    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(mapView)
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        var floodingActions: [SKAction] = []

        // wait a bit
        floodingActions.append(SKAction.wait(forDuration: 0.5))

        floodingActions.append(sfx)

        let startPosition = map.randomFloorPosition()!
        
        let bfd = map.breadthFirstDistanceFrom(x: startPosition.x, y: startPosition.y)
        let maxDistance = bfd.map({ $0.map({ $0 ?? 0 }).max() ?? 0 }).max() ?? 0

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.alpha = 0.5
        })

        for i in 0 ... maxDistance+1 {
            floodingActions.append(SKAction.run {
                self.mapView.waterTileMap.draw(map: self.map, bfd: bfd, distance: i, isDraining: false)
            })
            floodingActions.append(SKAction.wait(forDuration: 0.05))
        }
        
        // rising water level: alpha goes to 100%
        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
        })
        
        // wait a bit
        floodingActions.append(SKAction.wait(forDuration: 2.0))

        // switch to draining water tiles
        /*floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.draw(map: self.map, bfd: bfd, distance: maxDistance+1, isDraining: true)
        })*/
        
        // show boxes in random positions
        floodingActions.append(SKAction.run {
            for box in self.mapView.boxContainer.children {
                if let box = box as? Box {
                    if let object = self.map.objectsOfType(.box).first(where: { $0.id == box.id }) {
                     
                        let randomPostion = self.map.randomFloorPosition(adjacentTo: object.position)!
                        
                        let x = randomPostion.x
                        let y = randomPostion.y
                        
                        box.setMapPosition(x: x, y: y, tileMap: self.mapView.floorTileMap)
                    }
                }
            }
            self.mapView.boxContainer.isHidden = false
        })
        
        // wait a bit
        floodingActions.append(SKAction.wait(forDuration: 2.0))

//        let boxObjects = map.objectsOfType(.box)
//        let boxSprites = mapView.boxContainer.children
        
        // TODO: move boxes to correct position while draining water
        
        
        floodingActions.append(SKAction.run {
            for box in self.mapView.boxContainer.children {
                if let box = box as? Box {
                    
                    if let object = self.map.objectsOfType(.box).first(where: { $0.id == box.id }) {
                        
                        let x = object.position.x
                        let y = object.position.y
                        
                        let w = self.mapView.floorTileMap.frame.width / self.mapView.floorTileMap.xScale
                        let h = self.mapView.floorTileMap.frame.height / self.mapView.floorTileMap.yScale
                        
                        let xx = 32*(CGFloat(x)+0.5) - w/2
                        let yy = h/2 - 32*(CGFloat(y)+0.5)
                        
                        let randomTime1 = Double.random(in: 0.0 ... 1.0)
                        let randomTime2 = Double.random(in: 0.0 ... 1.0)

                        let waitAction = SKAction.wait(forDuration: randomTime1)
                        let moveAction = SKAction.move(to: CGPoint(x: xx, y: yy), duration: 1.0 + 2.0 * randomTime2)
                        moveAction.timingMode = .easeOut
                        box.run(SKAction.sequence([waitAction, moveAction]))
                    }
                }
            }
        })

        // wait a bit
        floodingActions.append(SKAction.wait(forDuration: 1.0))

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.run(SKAction.fadeAlpha(to: 0.3, duration: 2.0))
        })
        floodingActions.append(SKAction.wait(forDuration: 2.0))

        floodingActions.append(SKAction.run {
            self.mapView.waterTileMap.run(SKAction.fadeAlpha(to: 0.0, duration: 0.5))
        })
        floodingActions.append(SKAction.wait(forDuration: 0.5))

        // wait a bit
        floodingActions.append(SKAction.wait(forDuration: 1.0))

        floodingActions.append(SKAction.run {
            self.transition(to: Scene.gameScene, animated: false)
        })

        let floodingSequence = SKAction.sequence(floodingActions)
        mapView.run(floodingSequence)
        
    }

    func load(map: Map) {
        self.map = map
        mapView.update(with: map)
        mapView.hero.isHidden = true
        mapView.boxContainer.isHidden = true
    }
    
    override func handleKey(_ key: UIKey) {
        // any key goes to the game
        transition(to: Scene.gameScene, animated: false)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        mapView.hero.update(currentTime)
        
    }

}

// TODO: add tap gesture recognizer, that transitions back to the menu. Check menu buttons are still working (bug?)
