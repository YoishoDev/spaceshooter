//
//  CreditsScene.swift
//  Spaceshooter
//
//  Created by mis on 28.01.21.
//

import SpriteKit

class CreditsScene: SKScene {

    override func didMove(to view: SKView) {
        
    }
    
    // Klick auf Bild - zum Hauptmenue zurueck
    override func mouseDown(with event: NSEvent) {
        
        if let creditsImageNode = self.childNode(withName: "credits") {
        
            if atPoint(event.location(in: self)) == creditsImageNode {
                
                let transitionEffect = SKTransition.doorsOpenHorizontal(withDuration: 3) //verschiedene Übergangseffekte
                
                if let scene = SKScene(fileNamed: "MainMenuScene") {
                    
                    //Szene an View anpassen - im Zweifel SKS bearbeiten
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition: transitionEffect)
                    
                }
                    
            }
            
        }
    
    }
}
