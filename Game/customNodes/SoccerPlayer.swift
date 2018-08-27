//
//  Player.swift
//  antiSoccerGame2
//
//  Created by Rachel Corren on 7/9/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

/* this class is used to creat the soccer player nodes on the view */

import Foundation
import SpriteKit

class SoccerPlayer : SKSpriteNode {
    
    //the dimensions of the player sprite
    static let scaleFactor: CGFloat = 0.7
    static let playerWidth: Int = Int(50*scaleFactor)
    static let playerHeight: Int = Int(80*scaleFactor)
    //the margin between the goal and the first row of defense
    static let defenseToGoalMargin: Int = 300
    //margin between joystick and offense
    static let joyStickMargin: Int = 300
    //the texture arrays used to animate the players
    static let idleAtlas = SKTextureAtlas(named: "playerIdle")
    static let idleFrames: [SKTexture] = [idleAtlas.textureNamed("idle_0"),
                                          idleAtlas.textureNamed("idle_1"),
                                          idleAtlas.textureNamed("idle_2"),
                                          idleAtlas.textureNamed("idle_3")]
    static let runningAtlas = SKTextureAtlas(named: "playerRunning")
   
    static let runningRightFrames: [SKTexture] = [runningAtlas.textureNamed("runningRight_0"),
                                                  runningAtlas.textureNamed("runningRight_1"),
                                                  runningAtlas.textureNamed("runningRight_2")]
    static let runningLeftFrames: [SKTexture] = [runningAtlas.textureNamed("runningLeft_0"),
                                                  runningAtlas.textureNamed("runningLeft_1"),
                                                  runningAtlas.textureNamed("runningLeft_2")]
    //how fast each frame should last for
    static let frameDuration = 0.15
    //how far each player is allowed to travel to the ball
    static var playerMobilityRadius: Float = 150 //reset by the amount of space alloted
    //the duration it should take for a player to move to a point
    static var playerMoveTime: TimeInterval = 0.38
    //the node name to get the player nodes
    static let nodeName = "soccerPlayer"
    //the formation of the team to display (offense first defenese last)
    static let defaultFormation: [Int] = [3,3,1,3]
    //the list of random soccer formations to draw randomly from
    static let randomFormations: [[Int]] = [
        [3,3,1,3], [3,3,1,3], [4,2,1,3],
        [4,3,3], [4,4,1,1],
        [3,4,1,2], [3,4,1,2], [4,2,3,1],
        [3,3,1,3], [4,2,1,3] ]

    //the original position of the player to move back to after shifting
    var originalPosition: CGPoint!
    
    /* player constructor
     * @param point : the point to position the player at
     * */
    init (point: CGPoint) {
        /* call super constructor for its node props. and give node its properties */
        super.init(texture: nil,
                   color: UIColor.blue,
                   size: CGSize(width: SoccerPlayer.playerWidth,
                                height: SoccerPlayer.playerHeight))
        originalPosition = point // cgpoint is struct don't need to copy it (unique)
        position = originalPosition
        setUpPhysics()
        name = SoccerPlayer.nodeName
        setUpAnimation()
    }
    /* method to set the animation to idle */
    func runIdleAnimation () {
        /* don't run if it is already running */
        for index in 0...SoccerPlayer.idleFrames.count-1 {
            if (texture == SoccerPlayer.idleFrames[index]) {
                return
            }
        }
        /* run animation */
        run(SKAction.repeatForever(
            SKAction.animate(with: SoccerPlayer.idleFrames,
                             timePerFrame: SoccerPlayer.frameDuration,
                             resize: false,
                             restore: true)))
    }
    /* method to set the animation to running
     * @param moveTo: the point to to check for flipping textures
     * */
    func runRunningAnimation (moveTo: CGPoint) {
        /* get the right image atlas depending on which side running to */
        let runningTextures: [SKTexture] = (moveTo.x > position.x) ?
            SoccerPlayer.runningRightFrames : SoccerPlayer.runningLeftFrames
        /* don't run if it is already running */
        for index in 0...SoccerPlayer.runningRightFrames.count-1 {
            if (texture == SoccerPlayer.runningRightFrames[index] &&
                runningTextures == SoccerPlayer.runningRightFrames) {
                return
            }
            else if (texture == SoccerPlayer.runningLeftFrames[index] &&
                runningTextures == SoccerPlayer.runningLeftFrames) {
                return
            }
        }
        /* run animation */
        run(SKAction.repeatForever(
            SKAction.animate(with: runningTextures,
            timePerFrame: SoccerPlayer.frameDuration,
            resize: false,
            restore: true)))
    }
    /* method to animate the player */
    func setUpAnimation () {
        /* animate this player */
        run(SKAction.repeatForever(
            SKAction.animate(with: SoccerPlayer.idleFrames,
                             timePerFrame: SoccerPlayer.frameDuration,
                             resize: false,
                             restore: true)))
    }
    
    /* method to create physics of player */
    private func setUpPhysics () {
        physicsBody = SKPhysicsBody(rectangleOf:
            CGSize(width: SoccerPlayer.playerWidth, height: SoccerPlayer.playerHeight*4/5))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 0
    }
    /* method to choose a random formation
     * @return: an int [] of the formation
     */
    static func getRandomFormation () -> [Int] {
        /* generate rand number within arr range and pick that formation */
        //the random number in range
        let randomIndex = arc4random_uniform(UInt32(randomFormations.count))
        return randomFormations [Int(randomIndex)]
    }
    /* method to create the nodes needed to display a team
     * @param formationDefault: true if the formation should be default (for first level)
     * @param scene : the game scene to get the bounds from and add players to
     * @return : none
     * */
    static func createAndDisplayTeam (formationDefault: Bool, scene: GameScene){
        /* remove all players currently on the screen in case populated */
        scene.enumerateChildNodes(withName: SoccerPlayer.nodeName, using: {
            (node, stop) in
                node.removeFromParent()
        })
        /* get team formation to build */
        var teamFormation: [Int] = SoccerPlayer.defaultFormation
        if (!formationDefault) {
            teamFormation = getRandomFormation()
        }
        //scene height/width for one half
        let fieldHeight: Int = Int(scene.size.height) - defenseToGoalMargin - joyStickMargin
        let fieldWidth: Int = Int(scene.size.width)
        
        //vSpaceAlloted is the vertical spacing alloted for each row
        let vSpaceAlloted = fieldHeight / teamFormation.count
        /* iterate through the formation to get node positions */
        for fIndex in 1...teamFormation.count {
            /* skip if no players in the row */
            if (teamFormation[fIndex-1] == 0) {
                continue
            }
            //yPos is the y position for each player in the row, flipped if opposite team
            let yPos = vSpaceAlloted*fIndex - vSpaceAlloted/2 + playerHeight/2 - joyStickMargin
            //hSpaceAlloted is the horizontal space alloted for each player in the row
            let hSpaceAlloted = fieldWidth / teamFormation[fIndex-1]
            /* iterate through row to get x positions of indiv. players */
            for rIndex in 1...teamFormation[fIndex-1] {
                //xPos is the x position of the player
                var xPos = hSpaceAlloted * rIndex
                //shift the x position over since the coord. grid has 0 at middle
                xPos -= (Int(scene.size.width)/2 + hSpaceAlloted/2)
                /* add the player to the scene */
                scene.addChild(SoccerPlayer(point: CGPoint(x: xPos, y: yPos)))
            }
        }
    }
    /* method to move the closest player to the ball
     * @param scene: the scene the players exist on
     * */
    static func movePlayersToBall (scene: GameScene) {
        //the soccerball to reference to check for position
        let soccerBallNode: SKNode? = scene.childNode(withName: SoccerBall.nodeName)
        //the shortest distance and node for reference
        var shortestDistance: Float = 100000 //arbitrariry large fake distance
        var shortestDistanceNode: SoccerPlayer? = nil
        /* iterate through all the players to find the closest player to ball */
        scene.enumerateChildNodes(withName: SoccerPlayer.nodeName, using: {
            (node, stop) in
            //cast the node for easier reference to member properties
            let sp: SoccerPlayer = node as! SoccerPlayer
            /* if distance is shorter than shortest distance, replace if not out of its bound */
            let distanceToSoccerBall = hypotf(Float(soccerBallNode!.position.x - sp.position.x),
                                              Float(soccerBallNode!.position.y - sp.position.y))
            let distanceFromOriginalPosition = hypotf(Float(sp.position.x - sp.originalPosition.x),
                                                      Float(sp.position.y - sp.originalPosition.y))
            if (distanceToSoccerBall < shortestDistance
                && distanceFromOriginalPosition <= SoccerPlayer.playerMobilityRadius) {
                shortestDistance = distanceToSoccerBall
                shortestDistanceNode = sp
            }
            /* else move the player back to its original position if it is moving */
            else if (sp.hasActions()) {
                let moveBackToOriginalPos = SKAction.move(to: sp.originalPosition,
                                                          duration: SoccerPlayer.playerMoveTime)
                sp.run(moveBackToOriginalPos)
                sp.runIdleAnimation()
            }
        })
        /*  move the appropriate player to the ball if within bounds */
        let moveToSoccerBall = SKAction.move(to: soccerBallNode!.position,
                                             duration: SoccerPlayer.playerMoveTime)
        if ((shortestDistanceNode?.position.y)!
            > SoccerBall.startPosition.y + CGFloat(SoccerPlayer.playerHeight)+10) {
            shortestDistanceNode?.run(moveToSoccerBall)
            shortestDistanceNode?.runRunningAnimation(moveTo:(soccerBallNode!.position))
        } /* else move it to its original position */
        else {
            let moveBackToOriginalPos = SKAction.move(to: (shortestDistanceNode?.originalPosition)!,
                                                      duration: SoccerPlayer.playerMoveTime)
            shortestDistanceNode?.run(moveBackToOriginalPos)
            shortestDistanceNode?.runIdleAnimation()
        }
    }
    
    /* method to move the players back to their original positions
     * and resets their animations to idle
     * @param scene: the scene the players exist on
     * */
    static func movePlayersToOriginalPos (scene: GameScene) {
        /* iterate through all the players to move them back to original pos */
        scene.enumerateChildNodes(withName: SoccerPlayer.nodeName, using: {
            (node, stop) in
            let sp = node as! SoccerPlayer
            sp.run(SKAction.move(to: sp.originalPosition, duration: SoccerPlayer.playerMoveTime))
            /* reset the animation of the player */
            sp.runIdleAnimation()
        })
    }
    
    /* required decoder constructor, ignore */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
