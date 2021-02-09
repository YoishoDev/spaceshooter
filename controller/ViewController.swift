//
//  ViewController.swift
//  Spaceshooter
//
//  Created by mis on 25.01.21.
//

import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    private var viewControllerArray: [NSViewController] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //  ueber Klick auf Optionen benachrichtigen lassen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(optionsButtonClicked),
                                               name: Notification.Name("optionsButtonClicked"),
                                               object: nil)
        
        //Startmenue als erste Szene
        if let view = self.skView {
            
            // Szene-Datei laden
            if let scene = SKScene(fileNamed: "MainMenuScene") {
                
                //  Szene an View anpassen - im Zweifel SKS bearbeiten
                scene.scaleMode = .aspectFill
                
                // Szene zur View hinzufuegen
                view.presentScene(scene)
                
                //  Parameter der View
                skView.ignoresSiblingOrder = true
                
                //  Debug-Modus
                if isDebugMode {
                
                    skView.showsPhysics = true
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    
                }
            }
            
        }
        
    }
    
    //  auf Klick bei Optionen regaieren
    @objc func optionsButtonClicked() {
    
        //  Seque per Code
        performSegue(withIdentifier: NSStoryboard.SceneIdentifier("OptionsViewSeque"), sender: self)
        
    }
    
    //  Programmende
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        NSApplication.shared.terminate(self)
        
    }
    
}

