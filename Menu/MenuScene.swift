//
//  MenuScene.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/13/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import SpriteKit
import AVFoundation
import AVKit

class MenuScene: SKScene {
    
    /* basically the constructor for the view
     * @param view : program will take care of it
     */
    override func didMove(to view: SKView) {
        //the running soccer player frames and atlas containing it
        let runningAtlas = SKTextureAtlas(named: "playerRunning")
        var runningRightFrames = [SKTexture]()
        /* populate the array of running frames */
        for imageIndex in 0...runningAtlas.textureNames.count/2-1 {
            let runningTexture = runningAtlas.textureNamed("runningRight_\(imageIndex)")
            runningRightFrames.append(runningTexture)
        }
        /* animate the player to run forever */
        childNode(withName: "soccerPlayer")?.run(SKAction.repeatForever(
            SKAction.animate(with: runningRightFrames,
                             timePerFrame: 0.2, resize: false,restore: true)))
        /* animate the ball to rotate forever */
        childNode(withName: "soccerBall")?.run(SKAction.repeatForever((
            SKAction.rotate(byAngle: -1*CGFloat(Double.pi / 4), duration: 0.2)
        )))
        /* scale down the image for iphone x */
        enumerateChildNodes(withName: "title", using: {
            (node,stop) in
            if (GameViewController.iphoneX) {
                node.setScale(0.7)
            }
        })
    }
    
    /* method to handle the touches on the menu screen
     * ignore params
     * */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //the coord of the latest touch
        let lastTouchLocation = touches.first?.location(in: self)
        /* check for what object the touch is on */
        if (nodes(at: lastTouchLocation!).first?.name == "clickToPlay") {
            /* present the game scene */
            view?.presentScene(GameViewController.getGameScene(),
                               transition: GameViewController.sceneTranstion)
        }
    }
}
