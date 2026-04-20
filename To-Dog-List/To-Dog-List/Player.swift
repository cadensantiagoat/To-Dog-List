// Player Status (Level, Exp, Progression)

import Foundation

class Player {
    var level: Int = 1
    var currentExp: Int = 0
    
    func expNeededToLevelUp() -> Int {
        return level * 100
    }
    
    func addEXP(_ amount: Int) -> Bool {
        currentExp += amount
        
        if currentExp >= expNeededToLevelUp() {
            currentExp -= expNeededToLevelUp()
            level += 1
            return true
        }
        
        return false
    }
}
