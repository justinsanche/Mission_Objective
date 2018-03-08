//
//  GameViewController.swift
//  Mission Objective
//
//  Created by Justin Sanchez on 12/11/17.
//  Copyright © 2017 justinsanche. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    var backingAudio = AVAudioPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "backing audio", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL) }
        catch { return print("Cannot find the audio") }
        
        backingAudio.numberOfLoops = -1
        backingAudio.volume = 0.8
        backingAudio.play()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'MainMenuScene.swift'
            let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

