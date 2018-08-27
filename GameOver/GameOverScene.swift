//
//  GameOverScene.swift
//  antiSoccerGame2
//
//  Created by Cameron Smith on 7/13/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    //the score of the last game
    var score: Int = 0 //default val 0
    
    /* method to set the score of the last game
     * @param score: the score of the last game
     * */
    func setScore (score: Int) {
        /* set the score to be written in the psuedo constructor */
        self.score = score
    }
    
    /* basically the constructor for the view
     * @param view : program will take care of it
     */
    override func didMove(to view: SKView) {
        /* set the values of the labels on screen */
        (childNode(withName: "scoreLabel") as! SKLabelNode?)?.text = "Score: \(score)"
        (childNode(withName: "bestScoreLabel") as! SKLabelNode?)?.text =
            "Best Score: \(UserDefaults.standard.integer(forKey: GameScene.persistentScoreName))"
    }
    /* method to handle the touches on the menu screen
     * ignore params
     * */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //the coord of the latest touch
        let lastTouchLocation = touches.first?.location(in: self)
        /* check for what object the touch is on and move to appropriate scene*/
        if (nodes(at: lastTouchLocation!).first?.name == "restartGameButton" ||
            nodes(at: lastTouchLocation!).first?.name == "restartGameButtonOuter" ) {
            view?.presentScene(GameViewController.getGameScene(),
                               transition: GameViewController.sceneTranstion)
        }
        else if (nodes(at: lastTouchLocation!).first?.name == "restartMenu" ||
            nodes(at: lastTouchLocation!).first?.name == "restartMenuOuter" ) {
            view?.presentScene(GameViewController.getMenuScene(),
                               transition: GameViewController.sceneTranstion)
        }
    }
}
