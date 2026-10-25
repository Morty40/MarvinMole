//
//  MenuScene.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import SpriteKit

class MenuScene: DrippingScene {
        
    private var startTime: TimeInterval = 0.0

    /// When idle, the menu shows the demo, the dig scene and the credits in turns
    private enum IdleScene: CaseIterable { case demo, dig, credits }
    private var nextIdleScene = IdleScene.demo

    /// Rain falling over the whole background: in front of it, behind the title and buttons
    private lazy var rain = {
        let node = RainEmitter(size: size)
        node.position.x += center.x
        node.position.y += center.y
        node.zPosition = -1
        return node
    }()

    private lazy var backgroundImage = {
        let node = backgroundSprite(imageNamed: "MenuBackground", focus: CGPoint(x: 0.7, y: 0.5))
        node.zPosition = -2
        return node
    }()

    /// "MARVIN MOLE" logo, placed where it was in the original title screen
    // menu layout: everything is left aligned with the title logo. Sizes and margins are fractions of
    // the height (the same on every iPad; the width varies with the screen's shape). The fractions
    // are the logo's place in the original 4:3 title screen, 4/3 of a fraction of the 4:3 width.
    private var menuLeft: CGFloat { frame.size.height * 0.0575 * 4 / 3 }
    private let buttonSize = CGSize(width: 250, height: 90)
    private let buttonSpacing: CGFloat = 12

    /// "MARVIN MOLE" logo, placed where it was in the original title screen
    private lazy var titleImage = {
        let node = SKSpriteNode(imageNamed: "Title")
        let width = frame.size.height * 0.519 * 4 / 3
        node.size = CGSize(width: width, height: width * node.size.height / node.size.width)
        node.anchorPoint = CGPoint(x: 0, y: 0.5)
        node.position = CGPoint(x: menuLeft, y: frame.size.height * 0.843)
        return node
    }()

    /// "IN TUNNEL TROUBLE", below the logo, right aligned with it
    private lazy var subtitleImage = {
        let node = SKSpriteNode(imageNamed: "Subtitle")
        let width = frame.size.height * 0.399 * 4 / 3
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

        // straight into the game; the transition shows the level title
        Scene.gameScene.startCurrentMap(from: self)
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
        MapManager.shared.save()            // the menu reloads the saved state each time it appears
        
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
        MapManager.shared.save()            // the menu reloads the saved state each time it appears

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
#if DEBUG
        debugButtons.forEach { addChild($0) }
#endif
        
        refreshSelectedMap()
    }
    
    /// The scene is about to be presented by a view
    /// - Parameter view: The view that is presenting the scene
    override func didMove(to view: SKView) {
        backgroundImage.startKenBurns()
        rain.prewarm()
        startDripping()
        startMusic()
        startTime = 0.0
        
        MapManager.shared.load()
        refreshSelectedMap()
    }
    
    override func willMove(from view: SKView) {
        stopDripping()
        // the music keeps playing (e.g. into the demo); it fades out when a game starts
    }

    /// Background music: "Tunnel Tiptoe", an original loop rendered by Artwork/Music/compose_menu_music.py
    private static let musicFile = "MenuMusic.m4a"

    /// Loops the background music; carries on if it is already playing (back from the demo)
    private func startMusic() {
        MusicPlayer.shared.play(Self.musicFile, volume: 0.6)    // keep the drips audible on top
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
        
        // automatically go to demo mode, the dig scene or the credits (taking turns) after some time
        if startTime.isZero {
            startTime = currentTime
        } else if currentTime - startTime > 30.0 {
            show(nextIdleScene)
            let all = IdleScene.allCases
            nextIdleScene = all[(all.firstIndex(of: nextIdleScene)! + 1) % all.count]
        }
    }

    /// Goes to the demo, the dig scene or the credits
    private func show(_ idleScene: IdleScene) {
        startTime = 0.0
        switch idleScene {
        case .demo:
            // demo mode: the map floods first, then the demo plays it
            let map = Scene.demoScene.prepare()
            Scene.floodScene.load(map: map, then: Scene.demoScene)
            transition(to: Scene.floodScene)
        case .dig:
            Scene.digScene.prepare()
            transition(to: Scene.digScene)
        case .credits:
            transition(to: Scene.creditsScene)
        }
    }

#if DEBUG
    /// Small buttons on the right edge, to open the idle scenes straight away and to change which levels
    /// are solved; hidden until "+" is pressed
    private lazy var debugButtons: [TextButton] = {
        let buttons: [(String, Selector)] = [("Demo Mode", #selector(onDebugDemo)),
                                             ("Credits", #selector(onDebugCredits)),
                                             ("Start Digging", #selector(onDebugDig)),
                                             ("Solve All", #selector(onDebugSolveAll)),
                                             ("Unsolve All", #selector(onDebugUnsolveAll)),
                                             ("Solve Some", #selector(onDebugSolveSome))]
        let size = CGSize(width: 260, height: 60)
        let spacing: CGFloat = 10
        let height = CGFloat(buttons.count) * size.height + CGFloat(buttons.count - 1) * spacing
        return buttons.enumerated().map { i, button in
            let node = TextButton(title: button.0, target: self, action: button.1)
            node.size = size
            node.position = CGPoint(x: frame.size.width - 16 - size.width / 2,
                                    y: center.y + height / 2 - size.height / 2 - CGFloat(i) * (size.height + spacing))
            node.isHidden = true
            return node
        }
    }()

    override func handleKey(_ key: UIKey) {
        // "+" shows or hides the debug buttons
        if key.characters == "+" || key.keyCode == .keypadPlus {
            startTime = 0.0     // reset idle timer
            debugButtons.forEach { $0.isHidden.toggle() }
        }
    }

    @objc private func onDebugDemo() { show(.demo) }
    @objc private func onDebugCredits() { show(.credits) }
    @objc private func onDebugDig() { show(.dig) }
    @objc private func onDebugSolveAll() { setDebugSolved { true } }
    @objc private func onDebugUnsolveAll() { setDebugSolved { false } }
    @objc private func onDebugSolveSome() { setDebugSolved { Bool.random() } }

    /// Marks every level of every collection as solved or not, as `isSolved` says, and saves.
    /// A solved level gets its own solution from the level file.
    private func setDebugSolved(_ isSolved: () -> Bool) {
        startTime = 0.0     // reset idle timer
        MapManager.shared.solvedMaps = MapManager.MapCollection.allCases.flatMap { collection in
            (1 ... collection.count).compactMap { number -> MapManager.MapSolution? in
                let resourceName = String(format: collection.resourceName, number)
                guard isSolved(), let solution = Map.mapFromBundle(resource: resourceName)?.solution else {
                    return nil
                }
                return MapManager.MapSolution(resourceName: resourceName, moves: solution)
            }
        }
        MapManager.shared.save()
        refreshSelectedMap()
    }
#endif

}
