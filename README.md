# spaceshooter
# Einfacher Spaceshooter zum Erlernen von Swift und dem Umgang mit SpriteKit

Spiel-Idee:

Das Spiel soll sowohl unter macOS wie auch iOS spielbar sein. Die Steuerung unter macOS erfolgt durch frei wählbare Tasten für die Bewegungssteuerung.
Unter iOS wird das Raumschiff durch Bewegung des iPhones / iPads gesteuert.

Der Spieler steuert ein Raumschiff seiner Wahl durch mehrere Szenen. Das Raumschiff fliegt dabei mit einer sich im Spielverlauf steigenden Geschwindigkeit
geradeaus. Der Spieler kann sein Schiff nach links und rechts steuern, um den im All herumfliegenden Asteroiden auszuweichen. Zusätzlich kann er die Objekte auch mit Hilfe von Lasern zerstören.

Feindliche Raumschiffe versuchen das Schiff des Spielers zu zerstören, auch hier muss man etweder ausweichen oder schießen.

Vor Start des Spiels kann festgelegt werden, wieviele Leben das Raumschiff haben soll. Das Raumschiff verfügt über einen Schutzschirm, dessen Funktion sich mit jedem Treffer verringert. Ist der Schutzschirm inaktiv, so führt jeder Treffer eines feindlichen Schiffs oder Asteroiden zum Verlust eines Lebens. Der Schirm kann mit Hilfe von im Raum fliegenden Energie-Sonden aufgefüllt werden. Dazu müssen diese eingefangen werden.

Nach Verlust aller Leben ist das Spiel zu Ende.
