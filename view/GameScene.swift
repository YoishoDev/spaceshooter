//
//  GameScene.swift
//  Spaceshooter
//
//  Spiel-Szene (Weltraum)
//
//  Created by mis on 25.01.21.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //  Klassenvariablen

    //  Timer-Intervall
    var enemyShipInterval: Double       = GameDefaultValues.enemyShipInterval
    var asteroidInterval: Double        = GameDefaultValues.asteroidInterval
    var energySatelliteInterval: Double = GameDefaultValues.energySatelliteInterval
    
    //  Objekte erstellen (lassen)
    let creator = SpaceObjectsCreator()
    
    //  Kontakte nur einmal auswerten
    //  Rakete auf Asteroiden
    var contactLaserBulletAndAsteroidBegin: Bool = true
    //  Rakete auf feindliches Schiff
    var contactLaserBulletAndEnemyShipBegin: Bool = true
    //  Raumschiff und Asteroid 
    var contactSpaceShipAndAsteroidBegin: Bool = true
    //  Raumschiff und feindliches Raumschiff
    var contactSpaceShipAndEnemyShipBegin: Bool = true
    //  Raumschiff und Energie-Satellit
    var contactSpaceShipAndEnergySatelliteBegin: Bool = true
    
    //  Hintergrund
    let backgroundImage1 = SKSpriteNode(imageNamed: "background")
    let backgroundImage2 = SKSpriteNode(imageNamed: "background")
    
    //  Hintergrund-Musik
    var backgroundAudioPlayer = AVAudioPlayer()
    var isBackgroundSoundOn: Bool = true
    
    //  Button zum Menu
    let menuButtonNode = SKSpriteNode(imageNamed: "menuButton")
    
    //  Timer zum Erscheinen von Objekten
    var enemyShipTimer = Timer()
    var astroidTimer = Timer()
    var energySatelliteTimer = Timer()
    
    //  Leben und Energie des Raumschiffes
    var spaceShipLive: Int          = GameDefaultValues.spaceShipLive
    var spaceShipEnergy: Int        = GameDefaultValues.spaceShipEnergy
    var energyIncreaseValue: Int    = GameDefaultValues.energyIncreaseValue
    var unlimitedLive: Bool         = false
    
    //  Punkte
    var enemyShipScore: Int = 0
    var highScore: Int      = 0
    
    //  Benutzer-Einstellungen (aus Options)
    var userSettings        = UserDefaults.standard
    var sfxSoundOn: Bool    = GameDefaultValues.sfxOn
    
    //
    //  interne Funktionen
    //
    //  Benutzer-Einstellungen laden
    private func loadUserSettings() {
        
        //  unbegrenztes Leben
        if userSettings.bool(forKey: UserSettingsKeys.unlimitedLive) {
            
            unlimitedLive = true
            
        }
        //  SFX
        if userSettings.bool(forKey: UserSettingsKeys.sfxOn) {
            
            sfxSoundOn = true
            
        } else {
            
            sfxSoundOn = false
            
        }
        //  Anzahl der (gewuenschten) Leben
        if userSettings.integer(forKey: UserSettingsKeys.spaceShipLive) != 0 {
            
            //  initiale Anzahl der Leben nach Wunsch setzen
            spaceShipLive = userSettings.integer(forKey: UserSettingsKeys.spaceShipLive)
        }
        
        //  Energie
        if userSettings.integer(forKey: UserSettingsKeys.energyIncreaseValue) != 0 {
            
            //  Energiestufe
            energyIncreaseValue = userSettings.integer(forKey: UserSettingsKeys.energyIncreaseValue)
        }
        
        //  Spielstaende
        if userSettings.integer(forKey: UserSettingsKeys.highScore) != 0 {
            
            //  initiale Anzahl der Leben nach Wunsch setzen
            highScore = userSettings.integer(forKey: UserSettingsKeys.highScore)
        }
    }
    
    //  Sound vorbereiten
    private func prepareAudio() {
        
        //  Hintergrund-Musik
        if userSettings.bool(forKey: UserSettingsKeys.backgroundMusicOn) {
        
            do {
                
                //  Audio-Datei laden
                if let backgroundSoundFilePath = Bundle.main.path(forResource: "background", ofType: "mp3") {
                    
                    let backgroundSoundURL = URL(fileURLWithPath: backgroundSoundFilePath)
                    backgroundAudioPlayer = try AVAudioPlayer(contentsOf: backgroundSoundURL, fileTypeHint: nil)
                    //  unendlich oft abspielen
                    backgroundAudioPlayer.numberOfLoops = -1
                    //  Lautstaerke, ueber Options anpassbar
                    backgroundAudioPlayer.volume = 0.1
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
        
    }
    
    //  Hintergrund vorbereiten
    private func prepareSpaceBackground() {
        
        //  Position (x,y) = 0,0, "unten links"
        backgroundImage1.anchorPoint = CGPoint.zero
        backgroundImage1.position = CGPoint.zero
        backgroundImage1.size = self.size
        // z-Achse, 0 also derzeit die "unterste" Ebene
        backgroundImage1.zPosition = 0
        
        self.addChild(backgroundImage1)
        
        backgroundImage2.anchorPoint = CGPoint.zero
        //  zweiter Hintergrund nach unten versetzt - Ueberlagerung
        backgroundImage2.position.x = 0
        backgroundImage2.position.y = self.size.height - 5
        backgroundImage2.size = self.size
        backgroundImage2.zPosition = 0
        
        self.addChild(backgroundImage2)
        
        //  Button - zurueck zum Menue
        menuButtonNode.position.x = self.size.width - menuButtonNode.size.width - 10
        menuButtonNode.position.y = menuButtonNode.size.height + 10
        menuButtonNode.zPosition = 10
        
        self.addChild(menuButtonNode)
        
    }
    
    private func prepareGameInfos() {
        
        //  Leben
        //  Label
        //  Version 1.1 iosfonts.com
        let liveLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        liveLabel.text = "Leben:"
        liveLabel.fontColor = SKColor.yellow
        liveLabel.fontSize = 30
        liveLabel.position = CGPoint(x: 10 + liveLabel.frame.width / 2,
                                     y: self.size.height - liveLabel.frame.height * 1.5)
        liveLabel.zPosition = 10
        liveLabel.name = NodeNames.liveLabel
        
        self.addChild(liveLabel)
        
        //  grafische Darstellung der Leben
        //  Position nach Label ausrichten
        let xPosLiveNode: CGFloat = liveLabel.position.x + 10
        var xPosLastLiveNode: CGFloat = xPosLiveNode
        
        for index in 1 ... spaceShipLive {
                
            let liveNode = SKSpriteNode(imageNamed: "live")
            liveNode.position.x = xPosLiveNode + (CGFloat(index) + 1) * liveNode.size.width
            liveNode.position.y = self.size.height - liveNode.size.height + 5
            liveNode.zPosition = 10
            liveNode.setScale(0.8)
            //  ueber den Namen koennen wir auf die Nodes zugreifen
            liveNode.name = NodeNames.live + "_\(index)"
            xPosLastLiveNode = liveNode.position.x
            
            self.addChild(liveNode)
        }
        
        //  Energie
        //  Label
        //  Version 1.1 iosfonts.com
        let energyLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        energyLabel.text = "Energie:"
        energyLabel.fontColor = SKColor.yellow
        energyLabel.fontSize = 30
        energyLabel.zPosition = 10
        energyLabel.position = CGPoint(x: xPosLastLiveNode + 50 + liveLabel.frame.width / 2,
                                       y: self.size.height - liveLabel.frame.height * 1.5)
        
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        energyLabel.name = NodeNames.energyLabel
        
        self.addChild(energyLabel)
        
        //  volle Energie anzeigen
        addFullEnergyToSpaceShip()
        
        //  Spielstaende anzeigen
        //  von rechts anfangen
        //  Label High-Score-Wert
        //  Version 1.1 iosfonts.com
        let highScoreLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        highScoreLabel.text = "\(highScore)"
        highScoreLabel.fontColor = SKColor.yellow
        highScoreLabel.fontSize = 30
        highScoreLabel.zPosition = 10
        highScoreLabel.position = CGPoint(x: self.size.width - highScoreLabel.frame.size.width,
                                          y: self.size.height - liveLabel.frame.height * 1.5)
        
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        highScoreLabel.name = NodeNames.highScoreLabel
        
        self.addChild(highScoreLabel)
        
        //  Label High-Score Text
        //  Version 1.1 iosfonts.com
        let highScoreTextLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        highScoreTextLabel.text = "High Score:"
        highScoreTextLabel.fontColor = SKColor.yellow
        highScoreTextLabel.fontSize = 30
        highScoreTextLabel.zPosition = 10
        highScoreTextLabel.position = CGPoint(x: highScoreLabel.position.x - highScoreTextLabel.frame.size.width / 1.5,
                                              y: self.size.height - liveLabel.frame.height * 1.5)
        
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        highScoreTextLabel.name = NodeNames.highScoreTextLabel
        
        self.addChild(highScoreTextLabel)
        
        //  Label Feinde-Wert
        //  Version 1.1 iosfonts.com
        let enemyShipScoreLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        enemyShipScoreLabel.text = "\(enemyShipScore)"
        enemyShipScoreLabel.fontColor = SKColor.yellow
        enemyShipScoreLabel.fontSize = 30
        enemyShipScoreLabel.zPosition = 10
        enemyShipScoreLabel.position = CGPoint(x: highScoreTextLabel.position.x
                                                - highScoreTextLabel.frame.size.width / 1.5
                                                - enemyShipScoreLabel.frame.size.width / 1.5,
                                               y: self.size.height - liveLabel.frame.height * 1.5)
        
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        enemyShipScoreLabel.name = NodeNames.enemyShipScoreLabel
        
        self.addChild(enemyShipScoreLabel)
        
        //  Label Feinde Text
        //  Version 1.1 iosfonts.com
        let enemyShipScoreTextLabel = SKLabelNode(fontNamed: "Herculanum")
        //  Version 1.1 Lokalisierung
        enemyShipScoreTextLabel.text = "Feinde:"
        enemyShipScoreTextLabel.fontColor = SKColor.yellow
        enemyShipScoreTextLabel.fontSize = 30
        enemyShipScoreTextLabel.zPosition = 10
        enemyShipScoreTextLabel.position = CGPoint(x: enemyShipScoreLabel.position.x
                                                    - enemyShipScoreLabel.frame.size.width / 1.5
                                                    - enemyShipScoreTextLabel.frame.size.width / 1.5,
                                                   y: self.size.height - liveLabel.frame.height * 1.5)
        
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        enemyShipScoreTextLabel.name = NodeNames.enemyShipScoreTextLabel
        
        self.addChild(enemyShipScoreTextLabel)
        
    }
    
    
    //  Raumschiff vorbereiten
    private func addSpaceShipToScene() {
        
        // "Unser" Schiff
        let spaceShip: SKSpriteNode
        //  Bilder(namen) aus Optionen laden
        let spaceShipImageName = userSettings.string(forKey: UserSettingsKeys.spaceShipImageName)
        if spaceShipImageName != nil {
            
            spaceShip = creator.createSpaceObject(objectTyp: NodeTypes.SpaceShip,
                                                  nodeName: NodeNames.spaceShip)!
            
        } else {
            
            //  Default-Raumschiff verwenden
            spaceShip = creator.createSpaceObject(objectTyp: NodeTypes.SpaceShip,
                                                  nodeName: NodeNames.spaceShip)!
        
        }
        
        //  Groesse des Raumschiffs in Relation zur Szene
        spaceShip.size.width = SpaceShipScaleToScene * self.size.width / 100
        spaceShip.size.height = SpaceShipScaleToScene * self.size.height / 100
        
        //  Schiff in Szene positionieren
        spaceShip.position.x = self.size.width / 2
        spaceShip.position.y = spaceShip.size.height + 50
        
        //  Raumschiff zur Szene hinzufügen
        self.addChild(spaceShip)
    }
    
    @objc private func showEnemyShip() {
        
        // feindliches Raumschiff erzeugen
        if let enemyShip = creator.createSpaceObject(objectTyp: NodeTypes.EnemyShip,
                                                     nodeName: NodeNames.enemyShip) {
        
            //  feindliches Raumschiff erscheint bei x aus Bereich 0 - Breite der App
            //  Breite des Bildes links dazu und rechts abziehen!
            enemyShip.position = CGPoint(x: enemyShip.size.width +
                                            CGFloat(arc4random_uniform(UInt32(self.size.width - enemyShip.size.width))),
                                         y: self.size.height + enemyShip.size.height)
            
            //  feindliches Raumschiff nach unten bewegen bis unter dem Rand (- Höhe des Schiffs)
            let moveDown = SKAction.moveTo(y: -enemyShip.size.height, duration: GameDefaultValues.enemyShipMoveDuration)
            let remove = SKAction.removeFromParent()
            enemyShip.run(SKAction.sequence([moveDown,remove]))
            
            //  skalieren
            enemyShip.setScale(0.8)
            
            //  feindliches Raumschiff zur Szene hinzufügen
            self.addChild(enemyShip)
            
        }
        
    }
    
    @objc private func showAsteroid() {
        
        // Asteroid erzeugen
        if let asteroid = creator.createSpaceObject(objectTyp: NodeTypes.Asteroid,
                                                    nodeName: NodeNames.aesteroid) {
        
            //  Asteroid erscheint bei x aus Bereich 0 - Breite der App
            //  Breite des Bildes links dazu und rechts abziehen!
            asteroid.position = CGPoint(x: asteroid.size.width +
                                            CGFloat(arc4random_uniform(UInt32(self.size.width - asteroid.size.width))),
                                         y: self.size.height + asteroid.size.height)
            
            //  Asteroid nach unten bewegen bis unter dem Rand (- Höhe des Asteroid)
            let moveDown = SKAction.moveTo(y: -asteroid.size.height, duration: GameDefaultValues.asteroidMoveDuration)
            let remove = SKAction.removeFromParent()
            asteroid.run(SKAction.sequence([moveDown,remove]))
            
            //  skalieren
           asteroid.setScale(0.5)
            
            //  Asteroiden zur Szene hinzufügen
            self.addChild(asteroid)
            
        }
    }
    
    @objc private func showEnergySatellite() {
        
        // Energie-Satelliten erzeugen
        if let energySatellite = creator.createSpaceObject(objectTyp: NodeTypes.EnergySatellite,
                                                           nodeName: NodeNames.energySatellite) {
        
            //  Energie-Satelliten erscheint bei x aus Bereich 0 - Breite der App - Breite des Objektes
            energySatellite.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.size.width - energySatellite.size.width))),
                                               y: self.size.height + energySatellite.size.height)
            
            //  Energie-Satelliten nach unten bewegen bis unter dem Rand (- Höhe des Energie-Satelliten)
            let moveDown = SKAction.moveTo(y: -energySatellite.size.height, duration: 10)
            let remove = SKAction.removeFromParent()
            energySatellite.run(SKAction.sequence([moveDown,remove]))
            
            //  skalieren
            energySatellite.setScale(0.5)
            
            //  Energie-Satelliten zur Szene hinzufügen
            self.addChild(energySatellite)
            
        }
        
    }
    
    //  Laser-Rakete abschiessen
    private func fireALaserShot() {
        
        //  Raumschiff aus Szene laden
        if let spaceShip = self.childNode(withName: NodeNames.spaceShip) {
        
            //  Schiff bewaffnen
            let laserBullet = creator.createSpaceObject(objectTyp: NodeTypes.LaserBullet,
                                                        nodeName: NodeNames.laserBullet)
            
            //  Geschosse starten vom Raumschiff aus
            laserBullet?.position = spaceShip.position
            // Geschoss eine Ebene unter dem Raumschiff positionieren
            laserBullet?.zPosition = 1
            //  keinerlei Effekte
            laserBullet?.physicsBody?.isDynamic = false
            //  Sound hinzufuegen
            if sfxSoundOn {
                
                laserBullet?.run(SKAction.playSoundFileNamed("lasershot", waitForCompletion: true))
            
            }
            //  Laser-Geschoss abschießen und nach Verlassen der Szene entfernen
            let move = SKAction.moveTo(y: self.size.height + self.size.height, duration: 3)
            let remove = SKAction.removeFromParent()
            //run führt eine Sequenze (Reihe) von Actions aus, hier also bewegen und dann entfernen
            laserBullet?.run(SKAction.sequence([move, remove]))
            
            //  "Laser-Geschoss" zur Szene hinzufügen
            self.addChild(laserBullet!)
            
        }
        
    }
    
    //  Bewegung unseres Raumschiffes ausfuehren
    private func moveSpaceShip(direction: UInt32) {
        
        //  Raumschiff aus Szene laden
        if let spaceShip = self.childNode(withName: NodeNames.spaceShip) as? SKSpriteNode {
        
            // Richtung
            switch direction {
            
            case MovingDirection.left:
                
                let newPosX: CGFloat = spaceShip.position.x - 30
                //  nur wenn das Rauschiff nicht aus der Szene herausfliegen wuerde
                if newPosX > spaceShip.size.width {
                    
                    spaceShip.position.x = newPosX
                    
                } else {
                    
                    spaceShip.position.x = spaceShip.size.width * 0.5 - 30
                    
                }
                
            case MovingDirection.right:
                
                let newPosX: CGFloat = spaceShip.position.x + 30
                //  nur wenn das Rauschiff nicht aus der Szene herausfliegen wuerde
                if newPosX < self.size.width - spaceShip.size.width * 0.5 {
                    
                    spaceShip.position.x = newPosX
                    
                } else {
                    
                    spaceShip.position.x = self.size.width - spaceShip.size.width * 0.5 + 30
                    
                }
                
            default: break
            
            }
            
        }
        
    }
    
    //  Energie (wieder) komplett herstellen
    private func addFullEnergyToSpaceShip() {
        
        //  Position nach Energi-Label ausrichten
        //  Label-Node ueber Namen laden
        if let nodeName = childNode(withName: NodeNames.energyLabel) {
        
            let xPosLEnergyLevelNode: CGFloat = nodeName.position.x + nodeName.frame.width / 2 + 5
            //  Anzahl der moeglichen Nodes ermitteln
            let countEnergyLevelNodes = 100 / energyIncreaseValue
            for index in 1 ... countEnergyLevelNodes {
                    
                let energyLevelNode = SKSpriteNode(imageNamed: "energyLevel")
                energyLevelNode.position.x = xPosLEnergyLevelNode + (CGFloat(index) + 1) * energyLevelNode.size.width
                energyLevelNode.position.y = self.size.height - energyLevelNode.size.height
                energyLevelNode.zPosition = 10
                energyLevelNode.setScale(0.8)
                //  ueber den Namen koennen wir auf die Nodes zugreifen
                energyLevelNode.name = NodeNames.energy + "_\(index)"
                
                self.addChild(energyLevelNode)
            }
            
            //  und wieder volle Power
            spaceShipEnergy = 100
            
        }
        
    }
    
    //  beim "Beruehrung" zwischen Raumschiff und Energie-Satellite wird Energie zum
    //  Schiff hinzugefuegt
    private func addEnergyToSpaceShip(energySatelliteNode: SKNode) {
        
        //  Bewegung stoppen
        energySatelliteNode.removeAllActions()
        //  Raumschiff aus Szene laden
        guard let spaceShip = self.childNode(withName: NodeNames.spaceShip) else {
            return
        }
        //  Satellit an Raumschiff "heften"
        energySatelliteNode.position = spaceShip.position
        //  Satelliten "verschwinden lassen
        if sfxSoundOn {
            
            energySatelliteNode.run(SKAction.playSoundFileNamed("energy.mp3", waitForCompletion: false))
            
        }
        let fadeOutAction = SKAction.fadeOut(withDuration: 1)
        let removeAction = SKAction.removeFromParent()
        energySatelliteNode.run(SKAction.sequence([fadeOutAction, removeAction]))
        
        if (spaceShipEnergy == 100) {
            return
        }
        
        //  Infos aktualisieren
        //  Anzahl der moeglichen Nodes ermitteln
        let nodeIndex = spaceShipEnergy / energyIncreaseValue
        let nodeName = NodeNames.energy + "_\(nodeIndex)"
        guard let lastEnergyLevelNode = self.childNode(withName: nodeName) else {
            return
        }
        
        let energyLevelNode = SKSpriteNode(imageNamed: "energyLevel")
        energyLevelNode.position.x = lastEnergyLevelNode.position.x + energyLevelNode.size.width
        energyLevelNode.position.y = self.size.height - energyLevelNode.size.height
        energyLevelNode.zPosition = 10
        energyLevelNode.setScale(0.8)
        //  ueber den Namen koennen wir auf die Nodes zugreifen
        energyLevelNode.name = NodeNames.energy + "_\(nodeIndex + 1)"
        
        self.addChild(energyLevelNode)
        
        //  Energie erhoehen
        spaceShipEnergy += energyIncreaseValue
        
        
    }
    
    //  beim "Beruehrungen" zwischen Raumschiff und fremden Schiffen sowie Asteroiden wird die Energie
    //  des Schiffes reduziert
    private func decreaseEnergyOfSpaceShip() {
        
        if !unlimitedLive {
            
            if spaceShipEnergy - energyIncreaseValue == 0 {
                
                //  Keine Energie mehr, es wird um ein Leben reduziert
                if (decreaseSpaceShipLive()) {
                    
                    //  gleichzeitig wird wieder volle Energie "aufgeladen"
                    addFullEnergyToSpaceShip()
                    
                }
                
            //  Energie verringern
            } else {
                
                //  Infos aktualisieren
                //  aktuelle Anzahl an Nodes ermitteln
                let nodeIndex = spaceShipEnergy / energyIncreaseValue
                //  aktuell "letzten" EnergyLevelNode ermitteln
                let nodeName = NodeNames.energy + "_\(nodeIndex)"
                if let node = self.childNode(withName: nodeName) {
                
                    //  Node entfernen
                    node.removeFromParent()
                    
                }
                
                //  Energie verringern
                spaceShipEnergy -= energyIncreaseValue
                
            }
            
        }
        
    }
    
    //  Verringerung um ein Leben bei fehlender Energie
    //  ist noch ein Leben uebrig, dann wird Energie wieder auf 100 gesetzt
    private func decreaseSpaceShipLive() -> Bool {
        
        if !unlimitedLive {
            
            if (spaceShipLive > 1) {
                
                //  Infos aktualisieren
                //  aktuell "letzten" EnergyLevelNode ermitteln
                let nodeName = NodeNames.live + "_\(spaceShipLive)"
                if let node = self.childNode(withName: nodeName) {
                
                    //  Node entfernen
                    node.removeFromParent()
                    
                }
                
                //  Leben verringern
                spaceShipLive -= 1
                
                return true
                
            } else {
                
                endGame()
                
                return false
                
            }
            
        }
        
        return true
        
    }
    
    // feindliches Schiff oder Asteroiden explodieren lassen
    private func explodeAndRemove(node: SKNode) {
    
        let explosion = SKEmitterNode(fileNamed: "ExplosionParticleFile.sks")
        explosion?.position = node.position
        explosion?.zPosition  = 5
        self.addChild(explosion!)
        
        if sfxSoundOn {
            
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: true))
        
        }
        //2 sec. warten, dann Explosion entfernen
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        //  Objekt entfernen
        node.removeFromParent()
        
    }
    
    //  Punkte
    private func addScore(nodeType: UInt32) {
        
        //  Anzahl derTreffer erhoehen
        switch nodeType {
        
        case NodeTypes.EnemyShip: enemyShipScore += 1
        default: return
            
        }

        //  High-Score speichern?
        if enemyShipScore > highScore {
            
            highScore = enemyShipScore
            userSettings.set(highScore, forKey: UserSettingsKeys.highScore)
            
        }
        
        //  Spiel-Infos aktualisieren
        if let enemyShipScoreLabel = self.childNode(withName: NodeNames.enemyShipScoreLabel) as? SKLabelNode,
           let highScoreLabelNode = self.childNode(withName: NodeNames.highScoreLabel) as? SKLabelNode {
            
            enemyShipScoreLabel.text = "\(enemyShipScore)"
            highScoreLabelNode.text = "\(highScore)"
           
        }
        
    }
    
    //  Spiel-Ende
    private func endGame() {
        
        //  Spiel-Infos ausblenden
        if let liveLabelNode = self.childNode(withName: NodeNames.liveLabel),
           let energyLabelNode = self.childNode(withName: NodeNames.energyLabel)  {
            
            liveLabelNode.removeFromParent()
            energyLabelNode.removeFromParent()
        }
        if let liveNode = self.childNode(withName: NodeNames.live + "_1"),
           let energyNode = self.childNode(withName: NodeNames.energy + "_1")  {
            
            liveNode.removeFromParent()
            energyNode.removeFromParent()
        }
        if let highScoreTextLabelNode = self.childNode(withName: NodeNames.highScoreTextLabel),
           let highScoreLabelNode = self.childNode(withName: NodeNames.highScoreLabel)  {
            
            highScoreTextLabelNode.removeFromParent()
            highScoreLabelNode.removeFromParent()
        }
        if let enemyShipScoreTextLabel = self.childNode(withName: NodeNames.enemyShipScoreTextLabel),
           let enemyShipScoreLabel = self.childNode(withName: NodeNames.enemyShipScoreLabel)  {
            
            enemyShipScoreTextLabel.removeFromParent()
            enemyShipScoreLabel.removeFromParent()
        }
        //  Musik stoppen
        backgroundAudioPlayer.stop()
        //  Timer fuer feindliche Schiffe und Asteroiden stoppen
        astroidTimer.invalidate()
        enemyShipTimer.invalidate()
        energySatelliteTimer.invalidate()
        //  Raumschiff entfernen
        if let spaceShip = self.childNode(withName: NodeNames.spaceShip) {
            
            spaceShip.removeFromParent()
        }
        //  Label anzeigen, dann Hauptmenue zeigen
        let gameOverLabel = SKLabelNode(fontNamed: "Herculanum")
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.zPosition = 10
        //  zur Scene hinzufuegen
        self.addChild(gameOverLabel)
        
        //  Hauptmenue anzeigen
        if let mainMenuScene = SKScene(fileNamed: "MainMenuScene") {
            
            //Szene an View anpassen - im Zweifel SKS bearbeiten
            mainMenuScene.scaleMode = .aspectFill
            
            // Szene zur View hinzufuegen
            let transition = SKTransition.crossFade(withDuration: 10)
            self.view!.presentScene(mainMenuScene, transition: transition)
                
        }
        
    }
    
    //  Auruf beim Initialisieren der Szene
    override func didMove(to view: SKView) {
        
        //  für Benachrichtigung bei Kontakten der Physics anmelden
        self.physicsWorld.contactDelegate = self
        
        loadUserSettings()
        prepareAudio()
        prepareSpaceBackground()
        prepareGameInfos()
        addSpaceShipToScene()
        
        //  mehrere feindliche Raumschiffe sowie Asteroiden undn Energie-Satelliten tauchen aller x sec auf
        enemyShipTimer = Timer.scheduledTimer(timeInterval: enemyShipInterval, target: self,
                                              selector: #selector(self.showEnemyShip),
                                              userInfo: nil, repeats: true)
        astroidTimer = Timer.scheduledTimer(timeInterval: asteroidInterval, target: self,
                                              selector: #selector(self.showAsteroid),
                                              userInfo: nil, repeats: true)
        energySatelliteTimer = Timer.scheduledTimer(timeInterval: energySatelliteInterval, target: self,
                                                    selector: #selector(self.showEnergySatellite),
                                                    userInfo: nil, repeats: true)
        
    }
    
    // aus SKPhysicsContactDelegate - wird bei Kontakt von Objekten aufgerufen
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        //  Kontakt zwischen Raumschiff und feindlichem Schiff
        //  jeweils nur einmal auswerten
        if contactSpaceShipAndEnemyShipBegin {
            
            if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
                bodyB.categoryBitMask == PhysicsCategories.EnemyShip {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndEnemyShipBegin = false
                guard let node = bodyB.node else {
                    return
                }
                explodeAndRemove(node: node)
                decreaseEnergyOfSpaceShip()
            
            } else if   bodyA.categoryBitMask == PhysicsCategories.EnemyShip &&
                        bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndEnemyShipBegin = false
                guard let node = bodyA.node else {
                    return
                }
                explodeAndRemove(node: node)
                decreaseEnergyOfSpaceShip()
                
            }
        }
        
        //  Kontakt zwischen Raumschiff und Asteroid
        //  jeweils nur einmal auswerten
        if contactSpaceShipAndAsteroidBegin {
            
            if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
                bodyB.categoryBitMask == PhysicsCategories.Asteroid {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndAsteroidBegin = false
                guard let node = bodyB.node else {
                    return
                }
                explodeAndRemove(node: node)
                decreaseEnergyOfSpaceShip()
            
            } else if   bodyA.categoryBitMask == PhysicsCategories.Asteroid &&
                        bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndAsteroidBegin = false
                guard let node = bodyA.node else {
                    return
                }
                explodeAndRemove(node: node)
                decreaseEnergyOfSpaceShip()
                
            }
        }
        
        //  Kontakt zwischen Raumschiff und Energie-Satelliten
        //  jeweils nur einmal auswerten
        if contactSpaceShipAndEnergySatelliteBegin {
            
            if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
                bodyB.categoryBitMask == PhysicsCategories.EnergySatellite {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndEnergySatelliteBegin = false
                guard let node = bodyB.node else {
                    return
                }
                
                addEnergyToSpaceShip(energySatelliteNode: node)
            
            } else if   bodyA.categoryBitMask == PhysicsCategories.EnergySatellite &&
                        bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
                
                //  jeweils nur einmal auswerten
                contactSpaceShipAndEnergySatelliteBegin = false
                guard let node = bodyA.node else {
                    return
                }
                
                addEnergyToSpaceShip(energySatelliteNode: node)
                
            }
        }
        
        //  Kontakt zwischen Laser und feindlichem Schiff
        //  jeweils nur einmal auswerten
        if contactLaserBulletAndEnemyShipBegin {
            
            if  bodyA.categoryBitMask == PhysicsCategories.LaserBullet &&
                bodyB.categoryBitMask == PhysicsCategories.EnemyShip {
                
                //  jeweils nur einmal auswerten
                contactLaserBulletAndEnemyShipBegin = false
                guard let node = bodyB.node else {
                    return
                }
                
                //  feindliches Schiff explodieren lassen
                explodeAndRemove(node: node)
                //  Trefferanzahl erhoehen
                addScore(nodeType: NodeTypes.EnemyShip)
            
            } else if   bodyA.categoryBitMask == PhysicsCategories.EnemyShip &&
                        bodyB.categoryBitMask == PhysicsCategories.LaserBullet {
                
                //  jeweils nur einmal auswerten
                contactLaserBulletAndEnemyShipBegin = false
                guard let node = bodyA.node else {
                    return
                }
                
                //  feindliches Schiff explodieren lassen
                explodeAndRemove(node: node)
                //  Trefferanzahl erhoehen
                addScore(nodeType: NodeTypes.EnemyShip)
                
            }
        }
        
        //  Kontakt zwischen Laser und Asteroid
        //  jeweils nur einmal auswerten
        if contactLaserBulletAndAsteroidBegin {
            
            if  bodyA.categoryBitMask == PhysicsCategories.LaserBullet &&
                bodyB.categoryBitMask == PhysicsCategories.Asteroid {
                
                //  jeweils nur einmal auswerten
                contactLaserBulletAndAsteroidBegin = false
                guard let node = bodyB.node else {
                    return
                }
                
                //  Asteroid explodieren lassen
                explodeAndRemove(node: node)
                //  Trefferanzahl erhoehen
                addScore(nodeType: NodeTypes.Asteroid)
            
            } else if   bodyA.categoryBitMask == PhysicsCategories.Asteroid &&
                        bodyB.categoryBitMask == PhysicsCategories.LaserBullet {
                
                //  jeweils nur einmal auswerten
                contactLaserBulletAndAsteroidBegin = false
                guard let node = bodyA.node else {
                    return
                }
                
                //  Asteroid explodieren lassen
                explodeAndRemove(node: node)
                //  Trefferanzahl erhoehen
                addScore(nodeType: NodeTypes.Asteroid)
                
            }
            
        }
        
    }
    
    // aus SKPhysicsContactDelegate - wird nach Ende des Kontaktes von Objekten aufgerufen
    func didEnd(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        //  Kontakt zwischen Raumschiff und Asteroid
        if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
            bodyB.categoryBitMask == PhysicsCategories.EnemyShip {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndEnemyShipBegin = true

        
        } else if   bodyA.categoryBitMask == PhysicsCategories.EnemyShip &&
                    bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndEnemyShipBegin = true

        }
        
        //  Kontakt zwischen Raumschiff und Asteroid
        if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
            bodyB.categoryBitMask == PhysicsCategories.Asteroid {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndAsteroidBegin = true

        
        } else if   bodyA.categoryBitMask == PhysicsCategories.Asteroid &&
                    bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndAsteroidBegin = true

        }
        
        //  Kontakt zwischen Raumschiff und Energie-Satelliten
        if  bodyA.categoryBitMask == PhysicsCategories.SpaceShip &&
            bodyB.categoryBitMask == PhysicsCategories.EnergySatellite {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndEnergySatelliteBegin = true

        
        } else if   bodyA.categoryBitMask == PhysicsCategories.EnergySatellite &&
                    bodyB.categoryBitMask == PhysicsCategories.SpaceShip {
            
            //  jeweils nur einmal auswerten
            contactSpaceShipAndEnergySatelliteBegin = true

        }
        
        //  Kontakt zwischen Laser und feindlichem Schiff
        if  bodyA.categoryBitMask == PhysicsCategories.LaserBullet &&
            bodyB.categoryBitMask == PhysicsCategories.EnemyShip {
            
            //  jeweils nur einmal auswerten
            contactLaserBulletAndEnemyShipBegin = true

        
        } else if   bodyA.categoryBitMask == PhysicsCategories.EnemyShip &&
                    bodyB.categoryBitMask == PhysicsCategories.LaserBullet {
            
            //  jeweils nur einmal auswerten
            contactLaserBulletAndEnemyShipBegin = true

        }
        
        //  Kontakt zwischen Laser und Asteroid
        if  bodyA.categoryBitMask == PhysicsCategories.LaserBullet &&
            bodyB.categoryBitMask == PhysicsCategories.Asteroid {
            
            //  jeweils nur einmal auswerten
            contactLaserBulletAndAsteroidBegin = true

        
        } else if   bodyA.categoryBitMask == PhysicsCategories.Asteroid &&
                    bodyB.categoryBitMask == PhysicsCategories.LaserBullet {
            
            //  jeweils nur einmal auswerten
            contactLaserBulletAndAsteroidBegin = true

        }
    }
    
    //  Funktion wird vor Aktualisierung jedes Frame aufgerufen
    override func update(_ currentTime: TimeInterval) {
        
        //  Hintergruende werden pro Frame um 5 Punkte nach unten bewegt
        //  Version 1.1 Geschwindigkeit nach Schwierigkeit erhoehen
        backgroundImage1.position.y -= 5
        backgroundImage2.position.y -= 5
        
        if backgroundImage1.position.y < -backgroundImage1.size.height {
            
            backgroundImage1.position.y = backgroundImage2.position.y + backgroundImage2.size.height
        }
        
        if backgroundImage2.position.y < -backgroundImage2.size.height {
            
            backgroundImage2.position.y = backgroundImage1.position.y + backgroundImage1.size.height
        }
 
    }
    
    
    //  Tastatur, Touch- und Mouse-Events
    //
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func mouseDown(with event: NSEvent) {
        
        self.touchDown(atPoint: event.location(in: self))
        
        //  Menu-Button geklickt
        if atPoint(event.location(in: self)) == menuButtonNode {
            
            // Uebergang
            let transitionEffect = SKTransition.push(with: SKTransitionDirection.down, duration: 3.0)
            // Szene-Datei laden
            if let scene = SKScene(fileNamed: "MainMenuScene") {
                
                //Szene an View anpassen - im Zweifel SKS bearbeiten
                scene.scaleMode = .aspectFill
                
                // Szene zur View hinzufuegen
                self.view?.presentScene(scene, transition: transitionEffect)
                
            }
            
        }
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    //  Steuerung per Tastatur
    override func keyDown(with event: NSEvent) {
    
        //  Version 1.1 freie Tastaturbelegung
        //  Space, jetzt wird geschossen
        if event.keyCode == 49
        {
            fireALaserShot()
        }
        
        // Taste nach links
        if event.keyCode == 123
        {
            moveSpaceShip(direction: MovingDirection.left)
        }
        
        // Taste nach rechts
        if event.keyCode == 124
        {
            moveSpaceShip(direction: MovingDirection.right)
        
        }
    }
    
}
