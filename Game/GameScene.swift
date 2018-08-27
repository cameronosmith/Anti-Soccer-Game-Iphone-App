//
//  GameScene.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/9/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // the number of lives the user has on this level
    var numLives = 3
    //this level
    var level = 0
    //true if user has crossed threshhold for players to attack
    var playerCrossed = false
    //the name of the persistent score data to retrieve/set
    static let persistentScoreName = "highScore"
    //the powerups obj to reset the speeds after level or death
    let powerupsObj = Powerups()
       
    /* basically the constructor for the view
     * @param view : program will take care of it
     */
    
    override func didMove (to view: SKView) {
        /* set up physics for later */
        physicsWorld.contactDelegate = self
        /* set up game */
        resetGame()
        /* possible powerup for this level */
        Powerups.powerupGenerator(scene: self)
    }
    
    /* method to reset the game */
    func resetGame () {
        /* default values of the game props */
        numLives = 3
        level = 0
        playerCrossed = false
        /* add nodes */
        GameStatusBar.createStatusBar(scene: self, level: level)
        SoccerPlayer.createAndDisplayTeam(formationDefault: true, scene: self)
        //create goal must be called AFTER soccer players
        Field.createAndDisplayFieldAndGoal(scene: self)
        //draws ball sets up joystick response
        SoccerBall.createAndDisplayBall(scene: self) //must be called after goal drawn
        powerupsObj.resetSpeeds(scene: self)
    }
    //variables to limit the amount of collisions reported
    var lastPlayerCollisionUpdate: TimeInterval = Date().timeIntervalSince1970
    var lastPowerupCollisionUpdate: TimeInterval = Date().timeIntervalSince1970
    var collisionsBuffer: TimeInterval = 1 // the amount we should wait between collision reportings
    /* method to handle collisions */
    func didBegin(_ contact: SKPhysicsContact) {
        /* check for possible type collisions and delegate */
        if (contact.bodyA.node as? SoccerPlayer) != nil {
            /* break if last reporting was really recent */
            if (Date().timeIntervalSince1970 - lastPlayerCollisionUpdate < collisionsBuffer) {
                return
            }
            lastPlayerCollisionUpdate = Date().timeIntervalSince1970
            CollisionsHandler.handlePlayerCollision(scene: self,
                                                    ball: contact.bodyB.node as! SKSpriteNode)
            powerupsObj.resetSpeeds(scene: self)
        }
        else if (contact.bodyA.node as? Goal) != nil {
            if (Date().timeIntervalSince1970 - lastPlayerCollisionUpdate < collisionsBuffer) {
                return
            }
            lastPlayerCollisionUpdate = Date().timeIntervalSince1970
            advanceLevel()
        }
        else if ((contact.bodyB.node as! SKSpriteNode).name == "powerup") {
            /* break if last reporting was really recent */
            if (Date().timeIntervalSince1970 - lastPowerupCollisionUpdate < collisionsBuffer) {
                return
            }
            lastPowerupCollisionUpdate = Date().timeIntervalSince1970
            Powerups.powerupContact(scene: self, node: contact.bodyB.node as! SKSpriteNode)
        }
    }
    
    /* method to advance the level */
    func advanceLevel () {
        /* redraw level and increase difficulty */
        level += 1
        playerCrossed = false
        GameStatusBar.createAndDisplayScoreLabel (scene: self, score: level)
        SoccerPlayer.createAndDisplayTeam(formationDefault: false, scene: self)
        SoccerBall.createAndDisplayBall(scene: self)
        Powerups.powerupGenerator(scene: self)
        powerupsObj.resetSpeeds(scene: self)
        /* store score if new high score, check if null for first time use */
        if (level > UserDefaults.standard.integer(forKey: GameScene.persistentScoreName)) {
            UserDefaults.standard.set(level, forKey: GameScene.persistentScoreName)
        }
    }
    
    /* method to move to the game over scene */
    func moveToGameOverScene () {
        view?.presentScene(GameViewController.getGameOverScene(score: level),
                           transition: GameViewController.sceneTranstion)
    }
    /* method to handle a user touch
     * @param pos : the position of the touch
     */
    func touchDown(atPoint pos: CGPoint) {
    
    }
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       the next three methods handle delegate multiple touches as a single touch
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
    func touchMoved(toPoint pos : CGPoint) {
       touchDown(atPoint: pos)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     end of the methods to delegate multiple touches
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
    var lastUpdateTime: CFTimeInterval = 0.0 //the last timestamp of the update time interval
    var deltaTime: CFTimeInterval = 0.0 //the time since the last update ran through
    var timeSinceLastRun: CFTimeInterval = 0.0 //the aggregate time of not running through update fully
    var updateInterval: CFTimeInterval = 0.15 //how often the update code should run through
    
    /* method to update the frame at every time interval
     * @param currentTime  : the current time at this frame
     * */
    override func update(_ currentTime: TimeInterval) {
        /* update timer variables */
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastRun += deltaTime
        /* decrease update time since it causes weird moving in calling move too quickly */
        if (timeSinceLastRun > updateInterval) {
            /* move players to ball if ball crossed threshold */
            if (playerCrossed) {
                SoccerPlayer.movePlayersToBall(scene: self)
            }
            /* reset counter */
            timeSinceLastRun = 0
        }
    }
}
