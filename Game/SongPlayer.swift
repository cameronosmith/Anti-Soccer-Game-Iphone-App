//
//  SongPlayer.swift
//  antiSoccerGame2
//
//  Created by Cameron smith on 7/24/18.
//  Copyright © 2018 com.cameronSmith. All rights reserved.
//

import Foundation
import AVFoundation


class SongPlayer {
    
    static var song: AVAudioPlayer?
    
    static func playSong () {
        let path = Bundle.main.path(forResource: "Song.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            song = try AVAudioPlayer(contentsOf: url)
            song?.play()
            song?.numberOfLoops = -1
        } catch {
        }
    }
}
