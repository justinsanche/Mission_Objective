//
//  GameScene.swift
//  Mission Objective
//
//  Created by Justin Sanchez on 12/11/17.
//  Copyright © 2017 justinsanche. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: /*"playerShip"*/"player")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    var levelNumber = 0
    
    let bulletSound = SKAction.playSoundFileNamed("laserSound.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    let gameArea: CGRect
    
    //****************************************
    // Functions used for generating a random
    // CGFloat value
    //****************************************
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max:CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    enum gameState{
        case preGame //gamestate before game
        case inGame //gamestate in the game
        case afterGame //gamestate after the game
    }
    
    var currentGameState = gameState.preGame
    
    struct physicsCategories {
        
        static let none : UInt32 = 0
        static let player : UInt32 = 0b1 //1
        static let bullet : UInt32 = 0b10 //2
        static let enemy : UInt32 = 0b100 //4
        
    }
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playablewidth = size.height / maxAspectRatio
        let margin = (size.width - playablewidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playablewidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //****************************************
    // Moves all sprites into the view. Sets
    // up their physics bodies and their
    // positioning in the scene
    //****************************************
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        //setting score to 0 at the start of each game
        gameScore = 0
        
        let background = SKSpriteNode(imageNamed: /*background*/"spacebackground")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(0.8)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.player
        player.physicsBody!.collisionBitMask = physicsCategories.none
        player.physicsBody!.contactTestBitMask = physicsCategories.enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 60
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y:self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.5)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    func startNewLevel() {
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1: levelDuration = 2.5
        case 2: levelDuration = 1.75
        case 3: levelDuration = 1.0
        case 4: levelDuration = 0.5
        default:
            levelDuration = 3
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    func startGame() {
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height*0.5, duration: 1)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    //***************************************
    // Takes in the sprite to be rotated and
    // where it will be facing after the
    // rotation
    //***************************************
    func rotateSprite(sprite: SKSpriteNode, location: CGPoint?) {
        
        let deltaX = (location?.x)! - sprite.position.x
        let deltaY = (location?.y)! - sprite.position.y
        let angle = atan2(deltaY, deltaX) - CGFloat(Double.pi / 2)
        
        let rotate = SKAction.rotate(toAngle: angle, duration:0)
        
        sprite.run(rotate)
        
    }
    
    //*************************************
    // Takes care of all physics contacts
    // that are possible within the game
    //*************************************
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == physicsCategories.player && body2.categoryBitMask == physicsCategories.enemy {
            //if the player has hit the enemy
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            if livesNumber == 1 {
                
                body1.node?.removeFromParent()
                
            }
            
            body2.node?.removeFromParent()
            
            loseALife()
            
        }
        
        if body1.categoryBitMask == physicsCategories.bullet && body2.categoryBitMask == physicsCategories.enemy && (body2.node?.position.y)! < self.size.height {
            //if the bullet has hit the enemy
            
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        
    }
    
    //********************************************
    // Decrements one from your number of lives
    // and changes the number displayed on the
    // screen to represent this change.
    //********************************************
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let changeColor = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0)
        let returnColor = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0)
        let scaleSequence = SKAction.sequence([changeColor, scaleUp, scaleDown, returnColor])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
        
    }
    
    //*****************************************
    // Increment the game score by 1 when an
    // enemy is shot by the player. Increases
    // level (speed of enemies) depending upon
    // your current score.
    //*****************************************
    func addScore() {
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 5 || gameScore == 15 || gameScore == 30{
            startNewLevel()
        }
        
    }
    
    //*********************************
    // Spawns an enemy off the screen
    // in a random position and moves
    // it toward the player until it
    // is shot or collides with the
    // player.
    //*********************************
    func spawnEnemy() {
        
        var randomXStart : CGFloat
        var randomYStart : CGFloat
        
        //random int to choose which side the enemy will come from
        let spawnSide = arc4random() % 4 + 1
        
        switch spawnSide {
            //1=top 2=bottom 3=left 4=right
        case 1 ://top
            randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
            randomYStart = self.size.height * 1.2
            break
            
        case 2 ://bottom
            randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
            randomYStart = -self.size.height * 1.2
            break
            
        case 3 ://left
            randomXStart = -self.size.width * 1.2
            randomYStart = random(min: gameArea.minY, max: gameArea.maxY)
            break
            
        case 4 ://right
            randomXStart = self.size.width * 1.2
            randomYStart = random(min: gameArea.minY, max: gameArea.maxY)
            break
            
        default : //will just spawn right by default
            randomXStart = self.size.width * 1.2
            randomYStart = random(min: gameArea.minY, max: gameArea.maxY)
            break
            
        }
        
        let startPoint = CGPoint(x: randomXStart, y: randomYStart)
        let endPoint = player.position
        
        let enemy = SKSpriteNode(imageNamed: /*"enemyShip"*/"enemy")
        enemy.name = "Enemy"
        enemy.setScale(0.7)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.none
        enemy.physicsBody!.contactTestBitMask = physicsCategories.player | physicsCategories.bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 4)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    //**************************************
    // Changes to the game over scene
    //**************************************
    func changeScene(){
        
        let sceneToMoveTo = gameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
        
    }
    
    //*****************************************
    // Run when the game is over. This is
    // caused by either a player and enemy
    // collision or a enemy and bullet
    // collision. Changes to after game state
    //*****************************************
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    //***************************************
    // Spawns an explosion at the location
    // of a enemy-bullet collision or an
    // enemy-player collision. Plays explsion
    // sound too.
    //***************************************
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    //*****************************************
    // Fires a bullet from the player sprite
    // in the direction that the player tapped
    //*****************************************
    func fireBullet(location: CGPoint?) {
        
        let bullet = SKSpriteNode(imageNamed: /*"bullet"*/"laser")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.categoryBitMask = physicsCategories.bullet
        bullet.physicsBody!.collisionBitMask = physicsCategories.none
        bullet.physicsBody!.contactTestBitMask = physicsCategories.enemy
        self.addChild(bullet)
        
        rotateSprite(sprite: bullet, location: location)
        
        let moveX = player.position.x - (location?.x)!
        let moveY = player.position.y - (location?.y)!

        let deleteBullet = SKAction.removeFromParent()
        let moveBullet = SKAction.applyImpulse(CGVector(dx: -moveX, dy: -moveY), duration: 1)
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    //*************************************
    // Performs actions when a touch on
    // the screen is first registered
    //*************************************
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame {
            startGame()
        }
            
        else if currentGameState == gameState.inGame {
            
            for touch: AnyObject in touches {
                
                let location = touch.location(in: self)
                let sprite = player
                rotateSprite(sprite: sprite, location: location)
                fireBullet(location: location)
                
            }
            
        }
        
    }
            
}
