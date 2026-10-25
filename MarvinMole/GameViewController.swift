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
            view.showsFPS = false
            view.showsNodeCount = false
            view.ignoresSiblingOrder = false
            view.presentScene(scene)

            scene.transition(to: Scene.menuScene, animated: false)
        }
        view.addSubview(rotateHint)
        // its height comes from its icon and text; only its place is set (see viewDidLayoutSubviews)
        rotateHint.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rotateHint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            rotateHint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            rotateHintCenterY,
        ])
    }

    /// Puts the rotate hint in the middle of the bar below the game
    private lazy var rotateHintCenterY = rotateHint.centerYAnchor.constraint(equalTo: view.bottomAnchor)

    /// Shown in the black bar below the game while the iPad is upright: the game is made for landscape
    /// (iPadOS doesn't let an app keep itself in landscape, so in portrait it shows with bars)
    private lazy var rotateHint: UIView = {
        let icon = UIImageView(image: UIImage(systemName: "rotate.right",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)))
        icon.tintColor = .white
        let label = UILabel()
        label.text = "Turn your iPad sideways for the best view"
        label.font = UIFont(name: "Rubik-Bold", size: 24) ?? .boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.isUserInteractionEnabled = false
        stack.isHidden = true
        return stack
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // the game is shown at its own (landscape) shape, so upright there are bars above and below it
        let bounds = view.bounds
        let gameHeight = bounds.width * Scene.sceneSize.height / Scene.sceneSize.width
        let barHeight = (bounds.height - gameHeight) / 2
        rotateHint.isHidden = barHeight < 100
        // (only when it changes: changing it lays out the view again)
        if rotateHintCenterY.constant != -barHeight / 2 {
            rotateHintCenterY.constant = -barHeight / 2
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

