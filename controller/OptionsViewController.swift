//
//  OptionsViewController.swift
//  Spaceshooter
//
//  Created by mis on 04.02.21.
//

import Cocoa

class OptionsViewController: NSViewController {

    //  View-Elemente
    @IBOutlet weak var highScoreLabel: NSTextField!
    @IBOutlet weak var energyLevelCB: NSComboBox!
    @IBOutlet weak var liveCountCB: NSComboBox!
    @IBOutlet weak var unlimitedLive: NSButton!
    @IBOutlet weak var spaceShipImage: NSImageView!
    @IBOutlet weak var resetHighScoreCB: NSButton!
    @IBOutlet weak var sfxOnCB: NSButton!
    @IBOutlet weak var backgroundMusicOnCB: NSButton!
    @IBOutlet weak var unlimitedLiveCB: NSButton!
    
    //  Klassenvariablen
    //  Benutzer-Einstellungen (aus Options)
    var userSettings = UserDefaults.standard
    
    
    //  View mit Werten befuellen
    fileprivate func initializeView() {
        
        //  CB Energie-Level befuellen
        let energyValues: [String] = ["10","20","50","100"]
        energyLevelCB.addItems(withObjectValues: energyValues)
        
        //  evtl. gespeicherte Einstellung selektieren
        var value =  userSettings.integer(forKey: UserSettingsKeys.energyIncreaseValue)
        if energyValues.contains("\(value)") {
            
            energyLevelCB.selectItem(withObjectValue: "\(value)")
            
        } else {
            
            energyLevelCB.selectItem(withObjectValue: "10")
            
        }
        
        //  CB Anzahl Leben befuellen
        for index in 1 ... 5 {
            
            liveCountCB.addItem(withObjectValue: "\(index)")
            
        }
        
        //  evtl. gespeicherte Einstellung selektieren
        value =  userSettings.integer(forKey: UserSettingsKeys.spaceShipLive)
        if value > 0 && value < 6 {
            
            liveCountCB.selectItem(withObjectValue: "\(value)")
            
        } else {
            
            liveCountCB.selectItem(withObjectValue: "5")
            
        }
        
        //  evtl. Check-Boxen vorbelegen
        //  Hintergrundmusik
        if userSettings.bool(forKey: UserSettingsKeys.backgroundMusicOn) {
            
            backgroundMusicOnCB.state = NSControl.StateValue.on
            
        } else {
            
            backgroundMusicOnCB.state = NSControl.StateValue.off
            
        }
        //  SFX
        if userSettings.bool(forKey: UserSettingsKeys.sfxOn) {
            
            sfxOnCB.state = NSControl.StateValue.on
            
        } else {
            
            sfxOnCB.state = NSControl.StateValue.off
            
        }
        //  unbegrenztes Leben
        if userSettings.bool(forKey: UserSettingsKeys.unlimitedLive){
            
            unlimitedLiveCB.state = NSControl.StateValue.on
            
        } else {
            
            unlimitedLiveCB.state = NSControl.StateValue.off
            
        }
        
        //  High-Score anzeigen
        if userSettings.integer(forKey: UserSettingsKeys.highScore) > 0 {
        
            highScoreLabel.stringValue = "aktuell: \(userSettings.integer(forKey: UserSettingsKeys.highScore))"
            
        }
        
    }
    
    //  Events aus View
    //
    //  Einstellungen speichern
    @IBAction func saveButtonClicked(_ sender: NSButton) {
    
        //  Energie-Stufen
        var value = Int(energyLevelCB.objectValueOfSelectedItem as! String)
        userSettings.set(value, forKey: UserSettingsKeys.energyIncreaseValue)
        //  Anzahl Leben
        value = Int(liveCountCB.objectValueOfSelectedItem as! String)
        userSettings.setValue(value, forKey: UserSettingsKeys.spaceShipLive)
        //  Hintergrundmusik
        if backgroundMusicOnCB.state.rawValue == 1 {
        
            userSettings.setValue(true, forKey: UserSettingsKeys.backgroundMusicOn)
            
        } else {
            
            userSettings.setValue(false, forKey: UserSettingsKeys.backgroundMusicOn)
            
        }
        //  SFX
        if sfxOnCB.state.rawValue == 1 {
        
            userSettings.setValue(true, forKey: UserSettingsKeys.sfxOn)
            
        } else {
            
            userSettings.setValue(false, forKey: UserSettingsKeys.sfxOn)
            
        }
        //  unbegrenzte Leben
        if unlimitedLiveCB.state.rawValue == 1 {
        
            userSettings.setValue(true, forKey: UserSettingsKeys.unlimitedLive)
            
        } else {
            
            userSettings.setValue(false, forKey: UserSettingsKeys.unlimitedLive)
            
        }
        //  High-Score loeschen
        if resetHighScoreCB.state == NSControl.StateValue.on {
        
            userSettings.setValue(0, forKey: UserSettingsKeys.highScore)
            
        }
        self.view.window?.close()
    }
    
    //  View schliessen - kein Speichern
    //  version 1.1 bei getaetigten Aenderungen vorherfragen
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        
        self.view.window?.close()
    }
    
    
    //  wird beim Initialisieren aufgerufen
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeView()
        
    }
    
    //  wird vor Beendigung aufgerufen
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
    }
   
}
