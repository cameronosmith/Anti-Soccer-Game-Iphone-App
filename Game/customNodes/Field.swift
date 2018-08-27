//
//  Field.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/15/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class Field  {
    
    //the amount to scale the goalbox
    static let goalBoxScale: CGFloat = 0.7
    
    /* method to create the field and goal
     * @param scene: the scene to get dimensions from and add to
     * */
    static func createAndDisplayFieldAndGoal (scene: GameScene) {
        /* create the background grass */
        let fieldGrass = SKSpriteNode(imageNamed: "grassTexture")
        fieldGrass.zPosition = -5
        fieldGrass.size = CGSize(width: scene.size.width, height: scene.size.height)
        scene.addChild(fieldGrass)
        /* create and add the field node */
        let fieldPaint = SKSpriteNode(imageNamed: "customField")
        fieldPaint.zPosition = fieldGrass.zPosition + 1
        scene.addChild(fieldPaint)
        /* create the goalbox node and add it with the goal */
        Goal.createAndDisplayGoal (scene: scene)
        let goalPos = scene.childNode(withName: Goal.nodeName)?.position
        let goalBox = SKSpriteNode(imageNamed: "goalBox")
        goalBox.setScale(Field.goalBoxScale)
        goalBox.position = CGPoint(x: goalPos!.x,
                                   y: goalPos!.y - goalBox.size.height*Field.goalBoxScale)
        goalBox.zPosition =  fieldPaint.zPosition + 1
        scene.addChild(goalBox)
    }
}
