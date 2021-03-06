//
//  GameScene.swift
//  TestDragDrop
//
//  Created by Phyllis Wong on 1/21/18.
//  Copyright © 2018 Phyllis Wong. All rights reserved.


import SpriteKit
import AVFoundation

class DDLevelOne: SKScene {
    
    var start: DispatchTime?
    var end: DispatchTime?
    var totalTime: Double?
    
    var audio: AVAudioPlayer?
    var soundEffect: AVAudioPlayer?
    var player: SKSpriteNode!
    var matchShape: SKSpriteNode!
    
    var homeButton: SKButton!

    var isDragging = false
    

    override func didMove(to view: SKView) {
        
        // <<<<<<<<<< Start time in level
        self.start = DispatchTime.now()

        player = childNode(withName: "player") as! SKSpriteNode
        matchShape = childNode(withName: "matchShape") as! SKSpriteNode!
        
        /* Set UI connections */
        homeButton = self.childNode(withName: "homeButton") as! SKButton
        
        /* Setup button selection handler for homescreen */
        homeButton.selectedHandler = { [unowned self] in
            if let view = self.view {
                
                // FIXME: Load the SKScene from 'MainMenuScene.sks'
                if let scene = SKScene(fileNamed: "MainMenuScene") {
                    
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
                // Debug helpers
                view.showsFPS = true
                view.showsPhysics = true
                view.showsDrawCount = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // only perform these actions if the user touches on the shape
        if let touch = touches.first {
            if player.contains(touch.location(in: self)) {
                
                // increase the player size to que the user that they touches the piece
                player.size = CGSize(width: 250, height: 250)
                isDragging = true
                
                // MARK: cartoon voice here!
                self.playCartoonVoice()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDragging {
            if let touch = touches.first {
                movePlayerTo(location: touch.location(in: self))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let spinAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.5))
        let musicAction = SKAction.run { self.playSuccessMusic()}
        
        // let fadeAction = SKAction.fadeOut(withDuration: 2)
        // let fadeWithDelay = SKAction.sequence([SKAction.wait(forDuration: 2), fadeAction])
        // let spinWithSound = SKAction.group([spinAction, musicAction])
        
        let zoomAction = SKAction.scale(by: 2, duration: 1)
        let transitionAction = SKAction.run {
            self.transitionToScene()
        }
        
        let wait = SKAction.wait(forDuration: 1)
        let zoomWithTransition = SKAction.sequence([wait, zoomAction, transitionAction])
        
        isDragging = false
        
        // reset the player size to the original size
        player.size = CGSize(width: 230, height: 230)
        
        // Get the coordinates of the player when touch ends
        let xCoord = player.position.x
        let yCoord = player.position.y
        
        // Get the range around the matchShape
        let upperBoundx = matchShape.position.x + 30
        let upperBoundy = matchShape.position.y + 30
        let lowerBoundx = matchShape.position.x - 30
        let lowerBoundy = matchShape.position.y - 30

        // Check if the player is within the range of coordinates of the matchShape
        if lowerBoundx <= xCoord && xCoord <= upperBoundx {
            if lowerBoundy <= yCoord && yCoord <= upperBoundy {
                
                // <<<<<<<<<<   end time when level is complete
                self.end = DispatchTime.now()
                print(self.end as Any)
                
                // <<<<< Difference in nano seconds (UInt64) converted to a Double
                let nanoTime = Double((self.end?.uptimeNanoseconds)!) - Double((self.start?.uptimeNanoseconds)!)
                let timeInterval = (nanoTime / 1000000000)
                // print("timeInterval: \(timeInterval)")
                self.totalTime = timeInterval
                print("timeInterval: \(self.totalTime!)") /* <<<<<< save this value to db >>>>>> */
                
                player.run(spinAction)
                player.run(musicAction)
                self.run(zoomWithTransition)
                
            }
        }
    }
    
    
    
    // MARK: call this func when the user touches the player
    func playCartoonVoice() {
        if let asset = NSDataAsset(name: "yahoo"), let pop = NSDataAsset(name: "pop") {
            do {
                // Use NSDataAssets's data property to access the audio file stored in cartoon voice says yahoo.
                soundEffect = try AVAudioPlayer(data: pop.data, fileTypeHint: ".mp3")
                audio = try AVAudioPlayer(data: asset.data, fileTypeHint: ".mp3")
                // Play the above sound file
                soundEffect?.play()
                audio?.play()
            } catch let error as NSError {
                // Should print...
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: call this function when the user successfully completes the challenges
    func playSuccessMusic() {
        // Fetch the sound data set.
        if let music = NSDataAsset(name: "clown_music") {
            do {
                // Use NSDataAssets's data property to access the audio file stored in cartoon voice says yahoo.
                
                audio = try AVAudioPlayer(data: music.data, fileTypeHint: ".mp3")
                // Play the above sound file
                
                audio?.play()
            } catch let error as NSError {
                // Should print...
                print(error.localizedDescription)
            }
        }
    }
    
    
    func navigateToHomeScreen() {
        let home = MainMenuScene(fileNamed: "MainMenuScreen")
        home?.scaleMode = .aspectFill
        self.view?.presentScene(home!)
        print("did navigate to home")
    }
    
    
    func transitionToScene() {
        let levelTwo = DDLevelTwo(fileNamed: "DDLevelTwo")
        levelTwo?.scaleMode = .aspectFill
        audio?.stop()
        self.view?.presentScene(levelTwo!)
        print("Success")
    }
    
    
    func movePlayerTo(location: CGPoint) {
        player.position = location
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}


