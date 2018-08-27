//
//  CollisionsHandler.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/12/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//
//  This class is for the game scene to delgate collision types to

import Foundation
import AVFoundation
import SpriteKit

class CollisionsHandler {

    /* method to handle collision between soccer ball and player
     * @param scene: the game scene for reference
     * @param ball: the soccer ball to reset position
     * */
    static func handlePlayerCollision (scene: GameScene, ball: SKSpriteNode) {
        /* pretty sure we should remove this section, safe without it */
        if (scene.childNode(withName: SoccerBall.nodeName) == nil) {
            return
        }
        else {
            scene.childNode(withName: SoccerBall.nodeName)?.removeFromParent()
        }
        /* play lost life sound */
        //let s = Sounds()
        //s.playLostLifeSound()
        /* reset players not coming to ball */
        scene.playerCrossed = false
        /* move players back to original spots */
        SoccerPlayer.movePlayersToOriginalPos(scene: scene)
        /* reset soccer ball */
        SoccerBall.createAndDisplayBall(scene: scene)
        /* decrease num lives and display new num lives on status bar */
        scene.numLives -= 1
        /* vibrate screen and show heart lost animation */
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        /* if game is over than go to game over scene */
        if (scene.numLives == 0) {
            scene.moveToGameOverScene()
        }
        else {
            GameStatusBar.createHearts(numHearts: scene.numLives, scene: scene)
            /* if num lives 1 than ball is bruised */
            if (scene.numLives <= 2) {
                (scene.childNode(withName: SoccerBall.nodeName) as! SoccerBall).bruiseBall()
            }
        }
    }
}
