//
//  JoystickReduced.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/10/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class JoystickReduced {
    
    //definitions of the properties of joystick
    static let diameter: CGFloat = CGFloat (200)
    static let xPos = 0 //center
    static let yPos = -440
    static let bottomMargin = 10
    //define the images used
    static let joystickBase = UIImage(named: "jSubstrate")
    static let joystickPaddle = UIImage(named: "jStick")
    //the name of the joystick node
    static let nodeName = "joystick"
    
    /* method to add a joystick to the scene
     * @param scene: the scene to add the joystick to
     * @param object: the object to move in response to joystick movements
     * */
    static func addJoystick (scene: GameScene, responseNode: SKSpriteNode) {
        /* set up the joystick and add it to the scene */
        let joystick = AnalogJoystick(diameter: JoystickReduced.diameter, images:
            (JoystickReduced.joystickBase, JoystickReduced.joystickPaddle))
        joystick.name = JoystickReduced.nodeName
        joystick.position = CGPoint(x: JoystickReduced.xPos, y: JoystickReduced.yPos)
        joystick.setScale(0.8)
        addJoystickHandler (js: joystick, scene: scene, responseNode: responseNode)
        scene.addChild(joystick)
    }
    
    /* method to handle the tracking of the joystick
     * @param js: the joystick to set the handler on
     * @param scene: the scene to apply the hadnler to
     * @param responseNode: the node to move in response to the handler
     * */
    static func addJoystickHandler (js: AnalogJoystick, scene: GameScene,
                                    responseNode: SKSpriteNode) {
        /* set the handler properties */
        js.trackingHandler = { data in
            /* check if the ball crossed threshold */
            if (!scene.playerCrossed) {
                scene.playerCrossed = ballCrossedThreshold(scene: scene)
            }
            /* move the response node only if within bounds */
            //newPoint is the new position of the response node
            var newPoint = responseNode.position
            if (withinBoundsLateral(position: responseNode.position,
                                    scene: scene, jsData: data)) {
                    newPoint.x += data.velocity.x*SoccerBall.velocityModerator
            }
            if (withinBoundsVertical(position: responseNode.position,
                                    scene: scene, jsData: data)) {
                newPoint.y += data.velocity.y*SoccerBall.velocityModerator
            }
            responseNode.position = newPoint
            responseNode.zRotation = data.angular
            /* create trailing blood if lives count is 1 */
            if (scene.numLives == 1) {
                (responseNode as! SoccerBall).bloodyBall(scene: scene)
            }
        }
    }
    /* method to check whether the user has crossed the threshold for attack
     * @param scene: the scene to get the top player from
     * @return: true if user is eligible for attack
     * */
    static func ballCrossedThreshold (scene: GameScene) -> Bool {
        //the top offense y pos
        let topPlayerYPos = scene.childNode(withName: SoccerPlayer.nodeName)?.position.y
        //the soccerball position
        let ballYPos = scene.childNode(withName: SoccerBall.nodeName)?.position.y //this may be a layer violation
        /* check if the ball has crossed the first line of offense with a margin */
        if (ballYPos! > topPlayerYPos! - CGFloat(SoccerPlayer.playerHeight)) {
            return true
        }
        else{
            return false
        }
    }
    /* two methods to check whether the response node's bounds are
     * valid to keep moving in lateral and vertical directions
     * @param position: the position of the node to check for
     * @param jsData: the tracker data that wants to move it in a direction
     * @param scene: the scene to get bounds from
     * @return: true if valid to keep moving
     * */
    private static func withinBoundsLateral (position: CGPoint, scene: GameScene,
                                    jsData: AnalogJoystickData) -> Bool {
        /* check for within bounds */
        //right bound
        if (position.x >= scene.size.width/2 - CGFloat(SoccerBall.soccerBallDiameter)
            && jsData.velocity.x > 0) {
            return false
        }
        //left bound
        if (position.x <= -1*scene.size.width/2 + CGFloat(SoccerBall.soccerBallDiameter)
            && jsData.velocity.x < 0) {
            return false
        }
        return true
    }
    private static func withinBoundsVertical (position: CGPoint, scene: GameScene,
                                             jsData: AnalogJoystickData) -> Bool {
        /* check for within bounds */
        //upper bound
        if (position.y >= Goal.goalPosition.y - CGFloat(SoccerBall.soccerBallDiameter)
            && jsData.velocity.y > 0) {
            return false
        }
        //lower bound
        if (position.y <= SoccerBall.startPosition.y + CGFloat(SoccerBall.soccerBallDiameter)
            && jsData.velocity.y < 0) {
            return false
        }
        /* if here than valid move */
        return true
    }
}
