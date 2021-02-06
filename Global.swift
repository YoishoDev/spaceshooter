//
//  Global.swift
//  Spaceshooter
//
//  Created by mis on 05.02.21.
//

import Foundation

//  categoryBitMask-Values
internal struct PhysicsCategories {
    
    static let None: UInt32             = 0
    static let SpaceShip: UInt32        = 1
    static let LaserBullet: UInt32      = 2
    static let EnemyShip: UInt32        = 4
    static let Asteroid: UInt32         = 8
    static let EnergySatellite: UInt32  = 16
    
}

//  moegliche Objekt-Typen
internal struct NodeTypes {
    
    static let None: UInt32             = 0
    static let SpaceShip: UInt32        = 1
    static let LaserBullet: UInt32      = 2
    static let EnemyShip: UInt32        = 3
    static let Asteroid: UInt32         = 4
    static let EnergySatellite: UInt32  = 5
    
}

//  Namen der Nodes
internal struct NodeNames {
    
    static let unkown: String                   = "unknown"
    static let spaceShip:String                 = "spaceShip"
    static let enemyShip: String                = "enemyShip"
    static let aesteroid: String                = "aesteroid"
    static let energySatellite: String          = "energySatellite"
    static let laserBullet: String              = "laserBullet"
    static let liveLabel: String                = "liveLabel"
    static let live: String                     = "live"
    static let energyLabel: String              = "energyLabel"
    static let energy: String                   = "energy"
    static let enemyShipScoreTextLabel: String  = "enemyShipScoreTextLabel"
    static let enemyShipScoreLabel: String      = "enemyShipScoreLabel"
    static let highScoreTextLabel: String       = "highScoreTextLabel"
    static let highScoreLabel: String           = "highScoreLabel"
    
}

//  Bewegungsrichtungen
internal struct MovingDirection {
    
    static let unkown: UInt32   = 0
    static let left: UInt32     = 1
    static let right: UInt32    = 2
    static let up: UInt32       = 3
    static let down: UInt32     = 4
    
}

//  Spielvorgaben
internal struct GameDefaultValues {
    
    static let spaceShipLive: Int                   = 2
    static let spaceShipEnergy: Int                 = 100
    static let energyIncreaseValue: Int             = 50
    static let unlimitedLive: Bool                  = false
    static let sfxOn: Bool                          = true
    static let enemyShipInterval: Double            = 6.0
    static let enemyShipMoveDuration: Double        = 6.0
    static let asteroidInterval: Double             = 4.0
    static let asteroidMoveDuration: Double         = 10.0
    static let energySatelliteInterval: Double      = 10.0
    static let energySatellitepMoveDuration: Double = 6.0
    
}

//  Schluessel der Benutzer-Einstellungen
internal struct UserSettingsKeys {
    
    static let unkown: String               = "unknown"
    static let spaceShipImageName: String   = "SpaceShipImage"
    static let spaceShipLive: String        = "SpaceShipLive"
    static let spaceShipEnergy: String      = "SpaceShipLive"
    static let energyIncreaseValue: String  = "EnergyIncreaseValue"
    static let highScore: String            = "HighScore"
    static let backgroundMusicOn: String    = "backgroundMusicOn"
    static let sfxOn: String                = "sfxOn"
    static let unlimitedLive: String        = "unlimitedLive"
    
}
