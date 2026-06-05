//
//  GameViewController.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = Scene()
#if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
#endif
            view.ignoresSiblingOrder = false
            view.presentScene(scene)

            scene.transition(to: Scene.menuScene)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else {
            super.pressesBegan(presses, with: event)
            return
        }
                
        if let view = self.view as! SKView? {
            if let scene = view.scene as? Scene {
                scene.handleKey(key)
            }
        }
    }

}

