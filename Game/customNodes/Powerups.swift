//
//  Powerups.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/18/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class Powerups {
    //the dimensions of the timer bar
    static let timerBarMargin: CGFloat = 80 //the margin between goal and timer bar
    static let timerBarWidth = Goal.goalWidth + 30
    static let timerBarHeight = Goal.goalHeight
    //the texture array used to store our animations
    static var timerBarFrames = [SKTexture]()
    // the dimensions of the powerup
    static let powerupWidth: CGFloat = CGFloat(SoccerPlayer.playerWidth)
    static let powerupHeight: CGFloat = CGFloat(SoccerPlayer.playerHeight - 25)
    //the powerup textures
    static let extraHeartTexture = SKTexture(imageNamed: "healthBarHeart")
    static let lightningTexture = SKTexture(imageNamed: "lightning")
    static let stopwatchTexture = SKTexture(imageNamed: "stopwatch")
    //the time a powerup should last
    static let powerupTime: Double = 2.5
    
    //the game speeds before we modify them
    var soccerBallSpeed: CGFloat!
    var soccerPlayerSpeed: TimeInterval!
    
    /* constructor needed to save the original states before powerups mods. */
    init () {
        soccerBallSpeed = SoccerBall.velocityModerator
        soccerPlayerSpeed = SoccerPlayer.playerMoveTime
    }
    /* method to reset the original speeds before modifications
     * @param scene: the scene to remove the timer from
     */
    func resetSpeeds (scene: GameScene) {
        SoccerBall.velocityModerator = soccerBallSpeed
        SoccerPlayer.playerMoveTime = soccerPlayerSpeed
        /* remove timer bar if present */
        if scene.childNode(withName: "timerBar") != nil {
            scene.childNode(withName: "timerBar")?.removeFromParent()
        }
    }
    /* method to set up the animation frames for the timer bar */
    static func setUpTimerBarFrames () {
        //the atlas used to get the textures
        let framesAtlas = SKTextureAtlas(named: "timerBar")
        for frame in 0...framesAtlas.textureNames.count-1 {
            //the frame texture
            let texture: SKTexture = SKTexture(imageNamed: "timerBar_\(frame)")
            timerBarFrames.append(texture)
        }
    }
    /* method to draw and animate a timer bar for a powerup
     * @param scene: the scene to draw the timer bar on
     * */
    static func drawTimer (scene: GameScene) {
        /* set up animation frames if not already */
        if (timerBarFrames.count < 1) {
            setUpTimerBarFrames()
        }
        let timerBar = SKSpriteNode()
        timerBar.position = CGPoint(x: Goal.goalPosition.x + timerBarMargin + Goal.goalWidth,
                                    y: Goal.goalPosition.y)
        timerBar.name = "timerBar"
        timerBar.size = CGSize(width: timerBarWidth, height: timerBarHeight)
        /* get sequence and run animation */
        let timerSequence = SKAction.sequence([SKAction.animate(with: timerBarFrames,
                                                           timePerFrame: powerupTime/Double(timerBarFrames.count),
                                                           resize: false,
                                                           restore: true),
                                               SKAction.wait(forDuration: powerupTime),
                                          SKAction.run {timerBar.removeFromParent() }])
        scene.addChild(timerBar)
        timerBar.run(timerSequence)
    }
    /* method to handle the possible powerup
     * @param scene: the scene to possibly add the powerup to
     * */
    static func powerupGenerator (scene: GameScene) {
        /* delete if already on screen */
        if scene.childNode(withName: "powerup") != nil {
            scene.childNode(withName: "powerup")?.removeFromParent()
        }
        if scene.childNode(withName: "timerBar") != nil {
            scene.childNode(withName: "timerBar")?.removeFromParent()
        }
        /* random number to determine what powerup we are using */
        let randomNum = arc4random_uniform(UInt32(60))
        /* make the base node without its texture */
        let powerup = SKSpriteNode()
        powerup.position = getRandomPowerupPoint(scene: scene)
        powerup.name = "powerup"
        powerup.size = CGSize(width: powerupWidth, height: powerupHeight)
        powerup.physicsBody = SKPhysicsBody(rectangleOf:
            CGSize(width: SoccerPlayer.playerWidth, height: SoccerPlayer.playerHeight*4/5))
        powerup.physicsBody?.affectedByGravity = false
        powerup.physicsBody?.categoryBitMask = 1
        powerup.physicsBody?.collisionBitMask = 0
        /* set the image of the powerup */
        if randomNum < 10 { //generate stopwatch
            powerup.texture = stopwatchTexture
        }
        else if randomNum < 20 { //generate lightning bolt
            powerup.texture = lightningTexture
        }
        else if randomNum < 30 { //generate heart
            powerup.texture = extraHeartTexture
        }
        scene.addChild(powerup)
    }
    /* method to handle the initial powerup contact from gamescene
     * @param node: the node collided with
     * @param scene: the scene this was found on
     */
    static func powerupContact (scene: GameScene, node: SKSpriteNode) {
        //the name of the texture
        let powerupTexture = node.texture
        /* delegate to respective powerup handlers and remove powerup */
        if (powerupTexture == extraHeartTexture) {
            heartPowerup(scene: scene)
        } else if (powerupTexture == lightningTexture) {
            lightningPowerup(scene: scene)
        } else if (powerupTexture == stopwatchTexture) {
            stopwatchPowerup(scene: scene)
        }
        /* remove the powerup since used */
        node.removeFromParent()
    }
    
    /* method to handle the lightning bolt powerup
     * @param scene: the scene to draw the timer bar on
     * */
    static func lightningPowerup (scene: GameScene) {
        //the soccerball to increase speed
        let ball = scene.childNode(withName: SoccerBall.nodeName) as! SoccerBall
        //the powerup sequence for the scene to execute
        let lightningSequence = SKAction.sequence([SKAction.run {
            SoccerBall.velocityModerator *= 2 },
            SKAction.wait(forDuration: powerupTime),
            SKAction.run({
                SoccerBall.velocityModerator /= 2
            })])
        ball.run(lightningSequence)
        drawTimer(scene: scene)
    }
    /* method to handle the stopwatch powerup
     * @param scene: the scene to draw the timer bar on
     * */
    static func stopwatchPowerup (scene: GameScene) {
        //the player to apply the action to
        let player = scene.childNode(withName: SoccerPlayer.nodeName)
        //the sequence to decrease the speed
        let slowPlayerSequence = SKAction.sequence([SKAction.run {
            SoccerPlayer.playerMoveTime *= 2 },
           SKAction.wait(forDuration: powerupTime),
           SKAction.run({
            SoccerPlayer.playerMoveTime /= 2
           })])
        player?.run(slowPlayerSequence)
        drawTimer(scene: scene)
    }
    /* method to handle the heart powerup
     * @param scene: the scene to draw the timer bar on
     * */
    static func heartPowerup (scene: GameScene) {
        /* increase and redraw heart only if less than 3 */
        if (scene.numLives < 3) {
            scene.numLives += 1
            GameStatusBar.createHearts(numHearts: scene.numLives, scene: scene)
        }
    }
    /* method to get the random point to draw a powerup at
     * @param scene: the scene to get the position on
     * @return: the point to draw the pointat */
    static func getRandomPowerupPoint (scene: GameScene) -> CGPoint {
        /* get a random soccer player to put the powerup next to */
        let randomPlayerIndex = arc4random_uniform(UInt32(9))+1 //we don't want first player
        //counter for the number of players iterated
        var playersCounter = 0
        //the point to return
        var randomPoint = CGPoint(x: 0, y: -1000)
        //the last player iterated to store to determnine distance
        var lastPlayer: SKNode?
        //whether we need to recall this function
        var redo = false
        /* iterate through the players to get the position */
        scene.enumerateChildNodes(withName: SoccerPlayer.nodeName, using: {
            (node, stop) in
            /* if this is our player, stop searching */
            if (playersCounter == randomPlayerIndex) {
                stop.initialize(to: true)
                /* if these nodes are not in the same row, move to next */
                if (node.position.y != (lastPlayer?.position.y)!) {
                    redo = true
                }
                /* found the correct player, now calculate the point */
                randomPoint = CGPoint(x: (node.position.x+(lastPlayer?.position.x)!)/2 - CGFloat(SoccerPlayer.playerWidth/2),
                        y: node.position.y)
            }
            else { //didn't find the correct player, keep searching
                lastPlayer = node
                playersCounter += 1
            }
        })
        /* if case where last player was single and selected, redo */
        if (redo || randomPoint.y == -1000) {
           randomPoint = getRandomPowerupPoint(scene: scene)
        }
        return randomPoint
    }
}
