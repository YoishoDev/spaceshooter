//
//  MainMenuScene.swift
//  Spaceship
//
//  Scene-Editor-File: MainMenuScene.sks
//
//  Created by mis on 17.01.21.
//

import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {
    
    //  Klassenvariablen
    var backgroundAudioPlayer = AVAudioPlayer()
    
    override func didMove(to view: SKView) {
    
        //  Hintergrund-Musik
        do {
            
            //  Intro-Bild animieren
            if let introImage = self.childNode(withName: "introImage") {
                
                let fadeOutAction = SKAction.fadeAlpha(to: 0.1, duration: 3)
                let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 3)

                introImage.run(SKAction.repeatForever(SKAction.sequence([fadeInAction, fadeOutAction])))
                
            }
            
            //  Audio-Datei laden
            if let backgroundIntroSoundFilePath = Bundle.main.path(forResource: "intro", ofType: "mp3") {
                
                let backgroundIntroSoundURL = URL(fileURLWithPath: backgroundIntroSoundFilePath)
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: backgroundIntroSoundURL, fileTypeHint: nil)
                //  unendlich oft abspielen
                backgroundAudioPlayer.numberOfLoops = -1
                //  Lautstaerke, ueber Options anpassbar
                backgroundAudioPlayer.volume = 0.5
                //  abspielen
                backgroundAudioPlayer.prepareToPlay()
                backgroundAudioPlayer.play()
                
            } else {
                
                //  Version 1.1:    Logging
                print("Hintergrund-Sound-Datei wurde nicht gefunden!")
                
            }
            
        } catch {
            
            //  Version 1.1:    Logging
            print("Hintergrund-Sound konnte nicht abgesielt werden!")
        }
        
    }
    
    
    override func mouseDown(with event: NSEvent) {
        
        // Klick auf einen Button
        let clickLocation = event.location(in: self)
        let playButton: SKNode = self.childNode(withName: "playButton")!
        let optionsButton = self.childNode(withName: "optionsButton")!
        let creditsButton = self.childNode(withName: "creditsButton")!
        let exitButton = self.childNode(withName: "exitButton")!
        
        if atPoint(clickLocation) == playButton {
            
            backgroundAudioPlayer.stop()
            
            let transitionEffect = SKTransition.doorsOpenHorizontal(withDuration: 3) //verschiedene Übergangseffekte
            
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transitionEffect)
                
        }
        
        if atPoint(clickLocation) == optionsButton {
            
            backgroundAudioPlayer.stop()
            
            //  ViewController "informieren"
            NotificationCenter.default.post(name: Notification.Name("optionsButtonClicked"), object: self)
            
        }
        
        if atPoint(clickLocation) == creditsButton {
            
            backgroundAudioPlayer.stop()
            
            let transitionEffect = SKTransition.doorsOpenVertical(withDuration: 3) //verschiedene Übergangseffekte
            
            // Szene-Datei laden
            if let scene = SKScene(fileNamed: "CreditsScene") {
                
                //Szene an View anpassen - im Zweifel SKS bearbeiten
                scene.scaleMode = .aspectFill
                
                // Szene zur View hinzufuegen
                self.view?.presentScene(scene, transition: transitionEffect)

            }
            
                
        }
        
        if atPoint(clickLocation) == exitButton {
            
            //  Version 1.1 ist dies korrekt so?
            NSApplication.shared.terminate(view)
                
        }
    }
}
