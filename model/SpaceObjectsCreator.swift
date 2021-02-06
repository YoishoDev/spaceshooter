//
//  SpaceObjectsCreator.swift
//  Spaceshooter
//
//  Created by mis on 26.01.21.
//

import SpriteKit

class SpaceObjectsCreator {
    
    //  Klassenvariablen
    //
    //  Benutzereinstellungen
    var userSettigs: UserDefaults
    
    //  Kontruktor
    init() {
        
        //  Benutzereinstellungen
        userSettigs = UserDefaults.standard
        
    }
    
    //  interne Funktionen
    //
    private func createNode(objectTyp: UInt32, nodeName: String) -> (SKSpriteNode, String) {
        
        //  Image-(Namen) laden
        var nodeImageName: String
        //  Version 1.1 aus Optionen laden
        switch objectTyp {
        
        case NodeTypes.SpaceShip:
            
            nodeImageName = userSettigs.string(forKey: UserSettingsKeys.spaceShipImageName) ?? SpaceShipImageNames.first!
            
            
        case        NodeTypes.LaserBullet: nodeImageName = "LaserBullet"
        case        NodeTypes.EnemyShip: nodeImageName = "EnemyShip"
        case        NodeTypes.Asteroid: nodeImageName = "Asteroid"
        case        NodeTypes.EnergySatellite: nodeImageName = "EnergySatellite"
        default:    nodeImageName = ""
        }
        
        //  todo version 1.1: error handling
        let texture = SKTexture(imageNamed: nodeImageName)
        let node = SKSpriteNode(texture: texture)
        node.name = nodeName
        //  Physics "umrandet" das Bild
        node.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        //  alle Objekte (erstmal) drei Ebenen ueber dem Hintergrund
        node.zPosition = 3
        
        return (node, nodeImageName)
        
    }
    
    private func animateNode(node: SKSpriteNode, nodeImageName: String) {
        
        //  Bilder im Format <Bildname>-1....x.png
        var nodeArray = [SKTexture]()
        var index: UInt32 = 1
        //  Anzahl der Animationen (Bilder) ermitteln
        let fileManager = FileManager.default
        if var files = try? fileManager.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            files.sort()
            for filesIndex in 0...files.count - 1 {
                
                if files[filesIndex] == nodeImageName + "_\(index)" + ".png" {
                        
                    nodeArray.append(SKTexture(imageNamed: nodeImageName + "_\(index)"))
                    index+=1
                        
                }
                
            }
            if !nodeArray.isEmpty {
                
                node.run(SKAction.repeatForever(SKAction.animate(with: nodeArray, timePerFrame: 0.1)))
                
            }
            
        }
        
    }
    
    private func createSpaceShip(nodeName: String) -> SKSpriteNode {
        
        let (node, nodeImageName) = createNode(objectTyp: NodeTypes.SpaceShip, nodeName: nodeName)
        //  no gravity
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.SpaceShip
        //  no pysical collisions
        node.physicsBody?.collisionBitMask = PhysicsCategories.None
        //  contact with asteroids and enemies
        node.physicsBody?.contactTestBitMask = PhysicsCategories.Asteroid + PhysicsCategories.EnemyShip
        //  animate the node
        animateNode(node: node, nodeImageName: nodeImageName)
        
        return node
        
    }
    
    private func createLaserBullet(nodeName: String) -> SKSpriteNode {
        
        let (node, _) = createNode(objectTyp: NodeTypes.LaserBullet, nodeName: nodeName)
        //  no gravity
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.LaserBullet
        //  no pysical collisions
        node.physicsBody?.collisionBitMask = PhysicsCategories.None
        //  Kontakt mit Feinden und Asteroiden
        node.physicsBody?.contactTestBitMask = PhysicsCategories.EnemyShip + PhysicsCategories.Asteroid
        //  Node eine Ebene unter den anderen Objekten
        node.zPosition = 2
        
        return node
        
    }
    
    private func createEnemyShip(nodeName: String) -> SKSpriteNode {
        
        let (node, nodeImageName) = createNode(objectTyp: NodeTypes.EnemyShip, nodeName: nodeName)
        //  Physik
        // no gravity
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.EnemyShip
        //pysical collisions with asteroids and energy satellites
        node.physicsBody?.collisionBitMask = PhysicsCategories.None
        //contact with spaceship, asteroids, enemies and energy satellites
        node.physicsBody?.contactTestBitMask = PhysicsCategories.SpaceShip
        //  Raumschiff drehen, Angabe in Radient, Formel: PI/180 * gewünschte Drehung in Grad
        node.zRotation = CGFloat((Double.pi / 180) * 180)
        //animate the node
        animateNode(node: node, nodeImageName: nodeImageName)

        return node
        
    }
    
    private func createAsteroid(nodeName: String) -> SKSpriteNode {
        
        let (node, _) = createNode(objectTyp: NodeTypes.Asteroid, nodeName: nodeName)
        //  Physik
        // no gravity
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.Asteroid
        //  no pysical collisions
        node.physicsBody?.collisionBitMask = PhysicsCategories.None
        //contact with spaceship
        node.physicsBody?.contactTestBitMask = PhysicsCategories.SpaceShip

        return node
        
    }
    
    private func createEnergySatellite(nodeName: String) -> SKSpriteNode {
        
        let (node, nodeImageName) = createNode(objectTyp: NodeTypes.EnergySatellite, nodeName: nodeName)
        //  Physik
        // no gravity
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.EnergySatellite
        //no pysical collisions
        node.physicsBody?.collisionBitMask = PhysicsCategories.None
        //contact with spaceship
        node.physicsBody?.contactTestBitMask = PhysicsCategories.SpaceShip
        //animate the node
        animateNode(node: node, nodeImageName:nodeImageName)
        
        return node
        
    }
    
    public func createSpaceObject(objectTyp: UInt32, nodeName: String) -> SKSpriteNode? {
        
        switch objectTyp {
        
        case NodeTypes.None: return nil
        case NodeTypes.SpaceShip: return createSpaceShip(nodeName: nodeName)
        case NodeTypes.LaserBullet: return createLaserBullet(nodeName: nodeName)
        case NodeTypes.EnemyShip: return createEnemyShip(nodeName: nodeName)
        case NodeTypes.Asteroid: return createAsteroid(nodeName: nodeName)
        case NodeTypes.EnergySatellite: return createEnergySatellite(nodeName: nodeName)
        default: return nil
        }
        
    }
    
}
