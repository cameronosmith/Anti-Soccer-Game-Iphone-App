//
//  SoccerBall.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/10/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import SpriteKit

class SoccerBall: SKSpriteNode {
    
    // the starting position of the ball
    static let startPosition = CGPoint(x: 0, y: JoystickReduced.yPos + 185)
    //the ball texture
    static let ballTexture: SKTexture = SKTexture(imageNamed: "betterBall")
    //the bruised ball texture
    static let bruisedBallTexture: SKTexture = SKTexture(imageNamed: "bruisedBetterBall")
    //the name of the blood
    static let bloodName = "blood"
    //the list of blood sknodes to maintain so we don't create so many
    static var bloodNodes = [SKShapeNode]()
    //how fast the ball should go
    static var velocityModerator: CGFloat = 0.03
    
    //ball dimensions
    static let soccerBallDiameter = 30
    //the name to reference the node by
    static let nodeName = "soccerBall"

    /* player constructor
     * @param point : the point to position the player at
     * */
    init () {
        /* call super constructor for its node props. and give node its position */
        super.init(texture: SoccerBall.ballTexture,
                   color: UIColor.blue,
                   size: CGSize(width: SoccerBall.soccerBallDiameter,
                                height: SoccerBall.soccerBallDiameter))
        position = SoccerBall.startPosition
        /* give this ball physics properties */
        setPhysicsOfBall()
        name = SoccerBall.nodeName
        /* bruise ball if necessary */
    }
    
    /* method to bruise the ball */
    func bruiseBall() {
        texture = SoccerBall.bruisedBallTexture
    }
    
    /* method to trail the ball with a pool of blood
     * @param scene: the scene to add the ball to
     * */
    func bloodyBall(scene: GameScene) {
        /* create blood node and add it to the scene */
        let bloodyNode = SKShapeNode(ellipseOf: CGSize(width: SoccerBall.soccerBallDiameter - 5,
                                                       height: SoccerBall.soccerBallDiameter - 10))
        bloodyNode.position = CGPoint(x: position.x, y: position.y)
        bloodyNode.strokeColor = bloodyNode.fillColor
        bloodyNode.fillColor = UIColor.red
        bloodyNode.alpha = 0.3
        bloodyNode.name = SoccerBall.bloodName
        scene.addChild(bloodyNode)
        let bloodSequence = SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                               SKAction.run({bloodyNode.removeFromParent()})])
        bloodyNode.run(bloodSequence)
    }
    
    /* method to set up the physics properties of this ball */
    private func setPhysicsOfBall () {
        /* set its physics properties */
        physicsBody = SKPhysicsBody(texture: SoccerBall.ballTexture,
                                    size: CGSize(width: SoccerBall.soccerBallDiameter,
                                                 height: SoccerBall.soccerBallDiameter))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 0
        physicsBody?.collisionBitMask = 1
        physicsBody?.contactTestBitMask = 1
    }
    
    /* method to draw the soccer ball
     * @param scene : the scene to draw the ball on
     * @return : the ball node
     * */
    static func createAndDisplayBall (scene: GameScene) {
        /* remove ball and joystick if already exists */
        scene.childNode(withName: SoccerBall.nodeName)?.removeFromParent()
        scene.childNode(withName: JoystickReduced.nodeName)?.removeFromParent()
        /* create the ball and add it to the scene */
        let sc = SoccerBall()
        /* add the joystick handler to move the ball */
        JoystickReduced.addJoystick(scene: scene, responseNode: sc)
        if (scene.numLives < 3) {
            sc.bruiseBall()
        }
        scene.addChild(sc)
    }
    
    /* required decoder constructor, ignore */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
