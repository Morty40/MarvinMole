//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: Scene {
        
    private var startTime: TimeInterval = 0.0

    /// Rain falling over the whole background: in front of it, behind the title and buttons
    private lazy var rain = {
        let node = RainEmitter(size: size)
        node.position.x += center.x
        node.position.y += center.y
        node.zPosition = -1
        return node
    }()

    private lazy var backgroundImage = {
        let node = SKSpriteNode(imageNamed: "MenuBackground")
        node.position = center
        node.size = size
        node.zPosition = -2
        return node
    }()

    /// "MARVIN MOLE" logo, placed where it was in the original title screen
    // menu layout: everything is left aligned with the title logo
    private var menuLeft: CGFloat { frame.size.width * 0.0575 }
    private let buttonSize = CGSize(width: 250, height: 90)
    private let buttonSpacing: CGFloat = 12

    /// "MARVIN MOLE" logo, placed where it was in the original title screen
    private lazy var titleImage = {
        let node = SKSpriteNode(imageNamed: "Title")
        let width = frame.size.width * 0.519
        node.size = CGSize(width: width, height: width * node.size.height / node.size.width)
        node.anchorPoint = CGPoint(x: 0, y: 0.5)
        node.position = CGPoint(x: menuLeft, y: frame.size.height * 0.843)
        return node
    }()

    /// "IN TUNNEL TROUBLE", below the logo, right aligned with it
    private lazy var subtitleImage = {
        let node = SKSpriteNode(imageNamed: "Subtitle")
        let width = frame.size.width * 0.399
        node.size = CGSize(width: width, height: width * node.size.height / node.size.width)
        node.anchorPoint = CGPoint(x: 1, y: 0.5)
        node.position = CGPoint(x: titleImage.frame.maxX, y: frame.size.height * 0.783)
        return node
    }()

    private lazy var storyText = {
        let node = OutlinedLabel(fontName: "Rubik-Bold",
                                 fontSize: 30,
                                 horizontalAlignment: .left,
                                 verticalAlignment: .top,
                                 maxWidth: titleImage.size.width)
        node.position = CGPoint(x: menuLeft, y: frame.size.height * 0.742)
        node.text = "Oh dear!  Marvin Mole's home is flooded after the rain, and his food is all over the place.  Help him push his food back in the cupboards."
        return node
    }()

    /// Position of the n'th menu button (0 = top), stacked below the story text, left aligned with the title
    private func buttonPosition(_ n: Int) -> CGPoint {
        let top = storyText.position.y - storyText.textSize.height - 28
        return CGPoint(x: menuLeft + buttonSize.width / 2,
                       y: top - buttonSize.height / 2 - CGFloat(n) * (buttonSize.height + buttonSpacing))
    }

    private lazy var startButton = {
        let node = TextButton(title: "Start", target: self, action: #selector(onStart))
        node.size = buttonSize
        node.position = buttonPosition(0)
        return node
    }()
    
    @objc func onStart() {

        // reset idle timer
        startTime = 0.0
        
        MapManager.shared.save()

        MusicPlayer.shared.fadeOut(duration: 1.0)

        // load current map and transition
        Scene.loadingScene.loadCurrentMap()
        transition(to: Scene.loadingScene)
    }

    private lazy var mapCollectionButton = {
        let node = TextButton(title: MapManager.shared.selectedMap.collection.title, target: self, action: #selector(onMapCollection))
        node.size = buttonSize
        node.position = buttonPosition(1)
        return node
    }()
    
    @objc func onMapCollection() {
        
        // reset idle timer
        startTime = 0.0
        
        var index = MapManager.MapCollection.allCases.firstIndex(of: MapManager.shared.selectedMap.collection)!
        index = (index + 1) % MapManager.MapCollection.allCases.count
        MapManager.shared.selectedMap.collection = MapManager.MapCollection.allCases[index]
        MapManager.shared.selectedMap.number = 1
        
        refreshSelectedMap()
    }

    private lazy var mapNumberButton = {
        let node = TextButton(title: "Level \(MapManager.shared.selectedMap.number)", subtitle: "Unsolved", target: self, action: #selector(onMapNumber))
        node.size = buttonSize
        node.position = buttonPosition(2)
        return node
    }()
    
    @objc func onMapNumber() {
        
        // reset idle timer
        startTime = 0.0

        MapManager.shared.incrementMapNumber()

        refreshSelectedMap()
    }

    /// This is called once after the scene has been initialized,
    /// it's the recommended place to perform one-time setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        addChild(backgroundImage)
        addChild(rain)
        addChild(titleImage)
        addChild(subtitleImage)
        addChild(storyText)
        addChild(startButton)
        addChild(mapCollectionButton)
        addChild(mapNumberButton)
        
        refreshSelectedMap()
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        rain.prewarm()
        startDripping()
        startMusic()
        startTime = 0.0
        
        MapManager.shared.load()
        refreshSelectedMap()
    }
    
    override func willMove(from view: SKView) {
        removeAction(forKey: "drips")
        // the music keeps playing (e.g. into the demo); it fades out when a game starts
    }

    /// Background music: "Tunnel Tiptoe", an original loop rendered by Artwork/Music/compose_menu_music.py
    private static let musicFile = "MenuMusic.m4a"

    /// Loops the background music; carries on if it is already playing (back from the demo)
    private func startMusic() {
        MusicPlayer.shared.play(Self.musicFile, volume: 0.6)    // keep the drips audible on top
    }

    /// Single water drips, played in random order
    private let dripSounds = (1 ... 3).map {
        SKAction.playSoundFileNamed("Drip\($0).wav", waitForCompletion: false)
    }

    /// Soundscape of dripping water: a random drip every 1 to 3 seconds
    private func startDripping() {
        let drip = SKAction.sequence([
            SKAction.wait(forDuration: 2.0, withRange: 2.0),
            SKAction.run { [weak self] in
                if let self, let sound = self.dripSounds.randomElement() {
                    self.run(sound)
                }
            }])
        removeAction(forKey: "drips")
        run(SKAction.repeatForever(drip), withKey: "drips")
    }

    /// "Let's go!" when nothing is solved, "Done!" when everything is, otherwise the percentage.
    /// The percentage is rounded down (so 100% only shows when done) and is at least 1%.
    private func completionText(for collection: MapManager.MapCollection) -> String {
        let solved = MapManager.shared.numberOfSolvedMaps(in: collection)
        if solved == 0 {
            return "Let's go!"
        } else if solved >= collection.count {
            return "All done!"
        } else {
            return "\(max(1, solved * 100 / collection.count))% done!"
        }
    }

    private func refreshSelectedMap() {
        // map collection
        let collection = MapManager.shared.selectedMap.collection
        mapCollectionButton.title = collection.title
        mapCollectionButton.subtitle = completionText(for: collection)

        // map number, and whether it has been solved
        mapNumberButton.title = "Level \(MapManager.shared.selectedMap.number)"
        if let _ = MapManager.shared.mapSolutionFor(resourceName: MapManager.shared.selectedMap.resourceName) {
            mapNumberButton.subtitle = "Solved"

        } else {
            mapNumberButton.subtitle = "Unsolved"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // automatically go demo mode after some time
        if startTime.isZero {
            startTime = currentTime
        } else if currentTime - startTime > 30.0 {
            transition(to: Scene.demoScene)
        }
    }

}

// TODO: update UI according to selected map
