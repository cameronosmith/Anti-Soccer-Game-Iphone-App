//
//  GameStatusBar.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/12/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class GameStatusBar {
    
    //the base bar properties
    static var baseBarHeight: CGFloat = 100
    //health bar properties
    static let healthBarHeight: CGFloat = 70
    static let healthBarWidth: CGFloat = 200
    static let healthBarMargin: CGFloat = 15
    static let healthBarName = "healthBar"
    static let iphoneXScale: CGFloat = 0.7
    //heart icon properties
    static let heartMargin: CGFloat = 60 //space in between hearts
    static let heartHeight: CGFloat = healthBarHeight - 35
    static let heartWidth: CGFloat = (healthBarWidth-heartMargin*3)/3 + 40
    static let heartIconName = "heartIcon"
    static let heartTexture: SKTexture = SKTexture(imageNamed: "healthBarHeart")
    //name properties
    static let levelLabelNodeName = "levelLabel"
    
    /* main method to create the status bar
     * @param scene: the scene to add the status bar to
     * @param level: the level of the game
     * @return: none
     * */
    static func createStatusBar (scene: GameScene, level: Int) {
        if (GameViewController.iphoneX) {
            baseBarHeight += 50
        }
        createBaseBar(scene: scene)
        createHealthBar(scene: scene)
        createAndDisplayScoreLabel(scene: scene, score: level)
    }
    
    /* method to create background of the status bar
     * @param scene: the scene to get the dimensions from
     * @return : the background game node
     * */
    static func createBaseBar (scene: GameScene) {
        /* create the bar and add it to the scene */
        let baseBar: SKShapeNode = SKShapeNode(
            rectOf: CGSize (width: scene.size.width,
                           height: GameStatusBar.baseBarHeight))
        baseBar.position = CGPoint (x: 0,
                                    y: scene.size.height/2 - GameStatusBar.baseBarHeight/2)
        baseBar.fillColor = UIColor(red: 0, green: 100, blue: 0, alpha: 0.9)
        scene.addChild(baseBar)
    }
    /* method to create the health bar of the status bar
     * @param scene: the scene to get the dimensions from
     * @return : the health bar node
     * */
    static func createHealthBar (scene: GameScene) {
        /* create and add the health bar */
        let healthBar: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "healthBar"),
                                                   size: CGSize (width: healthBarWidth,
                                                                 height: healthBarHeight))
        healthBar.position = CGPoint (x: scene.size.width/2 - healthBarMargin - healthBarWidth/2,
                                      y: scene.size.height/2 - healthBarMargin - healthBarHeight/2)
        healthBar.name = healthBarName
        healthBar.zPosition = -1 //behind transparent base bar
        if (GameViewController.iphoneX) {
            healthBar.setScale(iphoneXScale)
            healthBar.position = CGPoint(x: healthBar.position.x - 50, y: healthBar.position.y - 25)
        }
        //healthBar.alpha = 0.3
        scene.addChild (healthBar)
        /* add the hearts to the health bar */
        createHearts(numHearts: scene.numLives, scene: scene)
    }
    /* method to draw the hearts
     * removes the hearts already present
     * @param numHearts: the number of hearts to draw
     * @param scene: the scene to add the hearts to
     * */
    static func createHearts (numHearts: Int, scene: GameScene) {
        /* can't draw 0 hearts */
        if (numHearts < 1) {
            return
        }
        /* remove all the preexisting hearts */
        scene.enumerateChildNodes(withName: heartIconName, using: {
            (node, stop) in
                node.removeFromParent()
        })
        //the health bar container for reference
        let healthBar: SKNode? = scene.childNode(withName: healthBarName)
        /* add the hearts to the scene */
        for heartIndex in 0...numHearts-1 {
            let heart: SKSpriteNode = SKSpriteNode(texture: heartTexture,
                                             size: CGSize(width: heartWidth, height: heartHeight))
            //the coordinate for the heart
            let yPos: CGFloat? = healthBar?.position.y
            //note the heart image needs to be replaced by the one we made
            let xPos: CGFloat? = (healthBar?.position.x)! - heartMargin + (heartMargin*CGFloat(heartIndex))
            heart.position = CGPoint(x:xPos!,y:yPos!)
            heart.zPosition = 4
            heart.name = heartIconName
            if (GameViewController.iphoneX) {
                heart.setScale(iphoneXScale)
            }
            scene.addChild(heart)
        }
    }
    /* method to draw the score label
     * @param scene: the game scene to add the label to
     * @param score: the score of the game
     * */
    static func createAndDisplayScoreLabel (scene: GameScene, score: Int) {
        /* remove label node if it exists */
        scene.childNode(withName: levelLabelNodeName)?.removeFromParent()
        /* create the label node, set its props, and add it to scene */
        let levelNode: SKLabelNode = SKLabelNode()
        levelNode.fontName = "LLPixel"
        levelNode.text = String("Score: \(score)")
        levelNode.fontSize = 60
        levelNode.position = CGPoint(x: 0,
                                     y: scene.size.height/2-baseBarHeight/2 - levelNode.fontSize/3)
        levelNode.name = levelLabelNodeName
        if (GameViewController.iphoneX) {
            levelNode.setScale(iphoneXScale)
        }
        scene.addChild(levelNode)
    }
    
}
