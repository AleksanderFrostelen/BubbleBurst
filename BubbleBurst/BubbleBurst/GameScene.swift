//
//  GameScene.swift
//  BubbleBurst
//
//  Created by Aleksander Frostelén on 2019-02-18.
//  Copyright © 2019 aleksander. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode?
    var ground: SKSpriteNode?
    var left: SKSpriteNode?
    var right: SKSpriteNode?
    var fire: SKSpriteNode?
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    
    var background = SKSpriteNode(imageNamed: "background")
    var replayButton: SKSpriteNode?
    
    
    private var foxWalkingFrames: [SKTexture] = []
    private var balloonHitFrames: [SKTexture] = []
    private var bombHitFrames: [SKTexture] = []
    
    
    var balloonTimer: Timer?
    var bombTimer: Timer?
    
    
    var score = 0
    var scoreLabel: SKLabelNode?
    var lives = 3
    var livesLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var pointsLabel: SKLabelNode?
    var floatingPointsLabel: SKLabelNode?
    
    
    let playerCategory: UInt32 = 0x1 << 1
    let balloonCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let boundsCategory: UInt32 = 0x1 << 4
    let arrowCategory: UInt32 = 0x1 << 5
    
    
    var balloonTimeInterval: Double = 1.9
    var bombTimeInterval: Double = 6
    var levelCounter: Int = 0
    var levelLabel: SKLabelNode?
    

    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = true
        physicsWorld.contactDelegate = self
        

        background.position = CGPoint(x: 0, y: 0)
        background.size = (scene?.size)!
        addChild(background)
        livesLabel = childNode(withName: "livesLabel") as? SKLabelNode
        livesLabel?.text = "LIVES  "+"\(lives)"
        background.zPosition = -1
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.text = "SCORE        0"
        scoreLabel?.zPosition = 10
      
        
        right = childNode(withName: "buttonRight") as? SKSpriteNode
        right?.zPosition = 5
        left = childNode(withName: "buttonLeft") as? SKSpriteNode
        left?.zPosition = 5
        fire = childNode(withName: "fire") as? SKSpriteNode
        fire?.zPosition = 5
        getBalloonHitFrames()
        getBombHitFrames()
        buildFox()
       

        startTimers(balloonTimeInterval: balloonTimeInterval, bombTimeInterval: bombTimeInterval)
        
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)
    
            if (touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonLeft")
                movePlayer(moveBy: 1000, forTheKey: "buttonRight")
            }
            if (touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonRight")
                movePlayer(moveBy: -1000, forTheKey: "buttonLeft")
            }
            if (touches.name == "fire") {
                createArrow()
            }
            if (touches.name == "fire" && touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonLeft")
                movePlayer(moveBy: 1000, forTheKey: "buttonRight")
                createArrow()
            }
            if (touches.name == "fire" && touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonRight")
                movePlayer(moveBy: -1000, forTheKey: "buttonLeft")
                createArrow()
            }
            if touches.name == "replay" {
                score = 0
                lives = 3
                levelCounter = 0
                balloonTimeInterval = 0.5
                bombTimeInterval = 3
                livesLabel?.text = "LIVES  "+"\(lives)"
                scoreLabel?.text = "SCORE        " + "\(score)"
                replayButton?.removeFromParent()
                yourScoreLabel?.removeFromParent()
                pointsLabel?.removeFromParent()
                scene?.isPaused = false
                startTimers(balloonTimeInterval: balloonTimeInterval, bombTimeInterval: bombTimeInterval)
              
            }            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)

            
            if (touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonRight")
                player?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonLeft")
                player?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "fire"){
                
            }
        }
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == balloonCategory, contact.bodyB.categoryBitMask == arrowCategory {
            score += 3
            balloonHit(sprite: contact.bodyA.node!, points: 3)
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == balloonCategory, contact.bodyA.categoryBitMask == arrowCategory {
            score += 3
            balloonHit(sprite: contact.bodyB.node!, points: 3)
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyA.categoryBitMask == bombCategory, contact.bodyB.categoryBitMask == arrowCategory  {
            score += 5
            bombHit(sprite: contact.bodyA.node!, points: 5)
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == bombCategory, contact.bodyA.categoryBitMask == arrowCategory {
            score += 5
            contact.bodyA.node?.removeFromParent()
            bombHit(sprite: contact.bodyB.node!, points: 5)
            
        }
        if contact.bodyA.categoryBitMask == playerCategory, contact.bodyB.categoryBitMask == balloonCategory {
        }
        if contact.bodyA.categoryBitMask == balloonCategory, contact.bodyB.categoryBitMask == playerCategory {
        }
        if contact.bodyA.categoryBitMask == playerCategory, contact.bodyB.categoryBitMask == bombCategory {
            score -= 10
            bombHit(sprite: contact.bodyB.node!, points: -10)
            lives -= 1
    
        }
        if contact.bodyA.categoryBitMask == bombCategory, contact.bodyB.categoryBitMask == playerCategory {
            lives -= 1
            score -= 10
            bombHit(sprite: contact.bodyA.node!, points: -10)
           
        }
        scoreLabel?.text = "SCORE        " + "\(score)"
        if lives != -1 {
            livesLabel?.text = "LIVES  "+"\(lives)"
        } else {
            gameOver(score: score)
        }
        
        if score > 15, levelCounter == 0 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 50, levelCounter == 1 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 200, levelCounter == 2 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 400, levelCounter == 3 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 600, levelCounter == 4 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 900, levelCounter == 5 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 1200, levelCounter == 6 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 1800, levelCounter == 7 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
    }

    
    func createBalloon() {
        let balloons = ["balloon1", "balloon2", "balloon3", "balloon4", "balloon5"]
        let selector = rng(max: 5, min: 0)
        let balloon = SKSpriteNode(imageNamed: balloons[Int(selector - 1)])
        balloon.zPosition = 4
        balloon.physicsBody = SKPhysicsBody(rectangleOf: balloon.size)
        balloon.physicsBody?.affectedByGravity = false
        balloon.physicsBody?.categoryBitMask = balloonCategory
        balloon.physicsBody?.contactTestBitMask = arrowCategory
        balloon.physicsBody?.collisionBitMask = 0
        addChild(balloon)
        spawnBalloon(sprite: balloon)
        
    }
    
    func getBalloonHitFrames() {
        let balloonAnimatedAtlas = SKTextureAtlas(named: "balloon")
        var exFrames: [SKTexture] = []
        let explosionTextureName = "balloon_explode"
        exFrames.append(balloonAnimatedAtlas.textureNamed(explosionTextureName))
        
        balloonHitFrames = exFrames
    }
    
    func balloonHit(sprite: SKNode, points: Int) {
        sprite.removeAllActions()
        sprite.physicsBody = nil
        let popSound = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
        let explode = SKAction.animate(with: balloonHitFrames,
                                       timePerFrame: 0.1,
                                       resize: false,
                                       restore: true)
        let seq = SKAction.sequence([popSound, explode, SKAction.removeFromParent()])
        
        sprite.run(seq, withKey: "balloonHit")
        
        showPoints(sprite: sprite, points: points)
        
    }
    
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        
        bomb.zPosition = 4
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: (bomb.size.width / 2) - (bomb.size.width / 8))
        bomb.physicsBody?.usesPreciseCollisionDetection = true
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = bombCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        spawnBomb(sprite: bomb)
    }
    
    func getBombHitFrames() {
        let bombAnimatedAtlas = SKTextureAtlas(named: "boom")
        var exFrames: [SKTexture] = []
        let explosionTextureName = "explosion"
        exFrames.append(bombAnimatedAtlas.textureNamed(explosionTextureName))
        
        bombHitFrames = exFrames
    }
    
    func bombHit(sprite: SKNode, points: Int) {
        sprite.removeAllActions()
        sprite.physicsBody = nil
        let bombSound = SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false)
        let explode = SKAction.animate(with: bombHitFrames,
                                       timePerFrame: 0.2,
                                       resize: false,
                                       restore: true)
        let seq = SKAction.sequence([bombSound, explode, SKAction.removeFromParent()])
        sprite.run(seq, withKey: "bombHit")
        
        showPoints(sprite: sprite, points: points)
    }
    
    func createArrow() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.zPosition = 4
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.categoryBitMask = arrowCategory
        arrow.physicsBody?.contactTestBitMask = balloonCategory | bombCategory
        arrow.physicsBody?.collisionBitMask = 0
        addChild(arrow)
        spawnArrow(sprite: arrow)
    }
    
    func spawnBalloon(sprite: SKSpriteNode) {
        
        let maxX = size.width / 2 - sprite.size.width / 2
        let minX = -size.width / 2 + sprite.size.width
        
        let range = maxX - minX
        let posX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        sprite.position = CGPoint(x: posX, y: size.height / 2 + sprite.size.height)
        
        
        let moveLeft = SKAction.moveBy(x: -size.width/20 , y: -size.height/2.5, duration: 4)
        let moveRight = SKAction.moveBy(x: size.width/20 , y: -size.height/2.5, duration: 4)
        let selector = arc4random_uniform(4)
        let number = 4 - selector
        if number == 1 {
            sprite.run(SKAction.sequence([moveLeft, moveRight, SKAction.removeFromParent()]))
        }
        if number == 2 {
            sprite.run(SKAction.sequence([moveRight, moveLeft, SKAction.removeFromParent()]))
        }
        if number == 3 {
            sprite.run(SKAction.sequence([moveRight, moveRight, SKAction.removeFromParent()]))
        }
        if number == 4 {
            sprite.run(SKAction.sequence([moveLeft, moveLeft, SKAction.removeFromParent()]))
        }
        
    }
    
    func spawnBomb(sprite: SKSpriteNode) {
        
        
        let maxX = size.width / 2 - sprite.size.width / 2
        let minX = -size.width / 2 + sprite.size.width
        
        
        let range = maxX - minX
        let posX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        sprite.position = CGPoint(x: posX, y: size.height / 2 + sprite.size.height)
        
        
        let drop = SKAction.moveBy(x: 0, y: -size.height - 2 * sprite.size.height, duration: 3)
        sprite.run(SKAction.sequence([drop, SKAction.removeFromParent()]))
        
    }
    
    func spawnArrow(sprite: SKSpriteNode) {
        
        sprite.position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)! - (player?.position.y)! / 2)
        
        let fire = SKAction.moveBy(x: 0, y: size.height, duration: 0.5)
        sprite.run(SKAction.sequence([fire, SKAction.removeFromParent()]))
        
    }

    
    func startTimers(balloonTimeInterval: Double, bombTimeInterval: Double) {
        balloonTimer = Timer.scheduledTimer(withTimeInterval: balloonTimeInterval, repeats: true, block: {
            timer in
            self.createBalloon()
        })
        bombTimer = Timer.scheduledTimer(withTimeInterval: bombTimeInterval, repeats: true, block: {
            timer in
            self.createBomb()
        })
        
        
    }
    
    
    func movePlayer(moveBy: CGFloat, forTheKey: String) {
        let moveAction = SKAction.moveBy(x: moveBy, y: 0, duration: 1)
        let repeatForEver = SKAction.repeatForever(moveAction)
        let seq = SKAction.sequence([moveAction, repeatForEver])
        player?.run(seq, withKey: forTheKey)
        animateFox()
       
        if forTheKey == "buttonRight" {
            player?.xScale = abs((player?.xScale)!) * -1.0
        }
        if forTheKey == "buttonLeft" {
            player?.xScale = abs((player?.xScale)!) * 1.0
        }
        
    }
    func buildFox() {
        let foxAnimatedAtlas = SKTextureAtlas(named: "fox")
        var walkFrames: [SKTexture] = []
        
        let numImages = foxAnimatedAtlas.textureNames.count
        for i in 0...numImages - 1 {
            let foxTextureName = "fox\(i)"
            walkFrames.append(foxAnimatedAtlas.textureNamed(foxTextureName))
        }
        foxWalkingFrames = walkFrames
        let firstFrameTexture = foxWalkingFrames[0]
        player = childNode(withName: "player") as? SKSpriteNode
        player?.texture = firstFrameTexture
        player?.size = firstFrameTexture.size()
        
        player?.zPosition = 4
        player?.physicsBody?.usesPreciseCollisionDetection = true
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.contactTestBitMask = bombCategory
        player?.physicsBody?.collisionBitMask = boundsCategory
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = boundsCategory
        ground?.physicsBody?.collisionBitMask = playerCategory
        leftWall = childNode(withName: "leftWall") as? SKSpriteNode
        leftWall?.physicsBody?.categoryBitMask = boundsCategory
        leftWall?.physicsBody?.collisionBitMask = playerCategory
        rightWall = childNode(withName: "rightWall") as? SKSpriteNode
        rightWall?.physicsBody?.categoryBitMask = boundsCategory
        rightWall?.physicsBody?.collisionBitMask = playerCategory
    }
    
    
    func animateFox() {
        player?.run(SKAction.repeatForever(
            SKAction.animate(with: foxWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                    withKey:"walkingFox")
        if player?.texture == nil {
            let atlas = SKTextureAtlas(named: "fox")
            let texture = atlas.textureNamed("fox0")
            player?.texture = texture
        }
    }
    
    

    func gameOver(score: Int) {
        scene?.isPaused = true
        bombTimer?.invalidate()
        balloonTimer?.invalidate()

        yourScoreLabel = SKLabelNode(text: "Your Score")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.zPosition = 11
        yourScoreLabel?.fontName = "Lucida Grande"
        yourScoreLabel?.fontSize = 64
        yourScoreLabel?.numberOfLines = 0
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        pointsLabel = SKLabelNode(text: "\(score)")
        pointsLabel?.position = CGPoint(x: 0, y: 0)
        pointsLabel?.zPosition = 11
        pointsLabel?.fontName = "Lucida Grande"
        pointsLabel?.fontSize = 150
        pointsLabel?.numberOfLines = 0
        if pointsLabel != nil {
            addChild(pointsLabel!)
        }
        
        replayButton = SKSpriteNode(imageNamed: "playbutton")
        replayButton?.position = CGPoint(x: 0, y: -150)
        replayButton?.zPosition = 11
        replayButton?.name = "replay"
        addChild(replayButton!)
    }
    
    func rng (max: Int, min: Int) -> Double {
        let max = max
        let min = min
        let range = max - min
        let number = Double(max) - Double(arc4random_uniform(UInt32(range)))
        return number
        
    }
    
    func levelUp(level : Int) {
    
        levelLabel = SKLabelNode(text: "Level " + "\(levelCounter)")
        levelLabel?.position = CGPoint(x: size.width, y: 0)
        levelLabel?.zPosition = 11
        levelLabel?.fontName = "Lucida Grande"
        levelLabel?.fontSize = 200
        if levelLabel != nil {
            addChild(levelLabel!)
        }
        spawnLabel(sprite: levelLabel!)
        balloonTimer?.invalidate()
        bombTimer?.invalidate()
        balloonTimeInterval -= 0.2
        bombTimeInterval -= 1
        startTimers(balloonTimeInterval: balloonTimeInterval, bombTimeInterval: bombTimeInterval)
        
    }
    
    func spawnLabel(sprite: SKLabelNode) {

        let dash1 = SKAction.moveTo(x: 0, duration: 0.8)
        let stop = SKAction.moveBy(x: 0, y: 0, duration: 1)
        let dash2 = SKAction.moveTo(x: -size.width, duration: 0.8)
        sprite.run(SKAction.sequence([dash1, stop, dash2, SKAction.removeFromParent()]))
        
    }
    
    func showPoints (sprite: SKNode, points: Int) {
        if points > 0 {
            floatingPointsLabel = SKLabelNode(text: "+\(points)")
        } else {
            floatingPointsLabel = SKLabelNode(text: "\(points)")
        }
        floatingPointsLabel?.position = sprite.position
        floatingPointsLabel?.zPosition = 11
        floatingPointsLabel?.fontName = "Comic Sans"
        floatingPointsLabel?.fontSize = 30
        addChild(floatingPointsLabel!)
        let goUp = SKAction.moveBy(x: 0, y: 30, duration: 1)
        floatingPointsLabel?.run(SKAction.sequence([goUp, SKAction.removeFromParent()]))
       
    }
    
}

