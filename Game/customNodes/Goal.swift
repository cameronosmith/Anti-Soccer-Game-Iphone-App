//
//  Goal.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/12/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class Goal : SKSpriteNode {
    
    //the name to reference it on the scene
    static let nodeName = "goal"
    //the goal image texture
    static let texture: SKTexture = SKTexture(imageNamed: "goalOld")
    //node dimensions
    static let goalHeight: CGFloat = 55
    static let goalWidth: CGFloat = 140
    static let insideGoalMargin: CGFloat = 0
    //margin from player to goal with y axis
    static let goalPlayerDiff: CGFloat = 150
    //the position of the goal
    static var goalPosition: CGPoint = CGPoint(x: 0, y: 0) //will be reset

    /* goal constructor
     * @param scene: the scene to get dimensions from and add the goal to
     * */
    init (scene: GameScene) {
        /* set up goal properties and add it to scene */
        super.init(texture: Goal.texture,
                   color: UIColor.blue,
                   size: CGSize(width: Goal.goalWidth,
                                height: Goal.goalHeight))
        Goal.goalPosition = CGPoint (x: 0,
            y: scene.size.height/2 - CGFloat(SoccerPlayer.defenseToGoalMargin) + Goal.goalPlayerDiff - 20)
        position = Goal.goalPosition
        name = Goal.nodeName
        setUpPhysics()
    }
    /* method to create the goal, just a wrapper of the constructor for convention
     * @param scene: the scene to add the goal to   
     * */
    static func createAndDisplayGoal (scene: GameScene) {
        scene.addChild(Goal(scene: scene))
    }
    /* method to create physics of player */
    private func setUpPhysics () {
        /* set up physics properties */
        physicsBody = SKPhysicsBody(rectangleOf:
            CGSize(width: Goal.goalWidth - Goal.insideGoalMargin,
                   height: Goal.goalHeight))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 0
    }
    
    /* required decoder constructor, ignore */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
