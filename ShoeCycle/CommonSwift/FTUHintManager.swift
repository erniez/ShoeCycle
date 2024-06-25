//  FTUAlertManager.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/12/23.
//  
//

import Foundation


struct FTUHintManager {
    // Hint Keys
    static let hintStravaFeature = "ShoeCycleFTUStravaFeature"
    static let hintSwipeFeature = "ShoeCycleFTUSwipeFeature"
    static let hintEmailHistoryFeature = "ShoeCycleFTUEmailHistoryFeature"
    static let hintHOFFeature = "ShoeCycleFTUHOFFeature"
    static let hintGraphAllShoesFeature = "ShoeCycleFTUGraphAllShoesFeature"
    static let hintYearlyHistoryFeature = "ShoeCycleFTUYearlyHistoryFeature"
    static let completedHintsKey = "ShoeCycleFTUCompletedFeatures"

    // Hint Info Strings
    static let hintInfoStravaFeature = "You can integrate with Strava! Add your runs to Strava as easily as tapping the \"+\" button.  Just tap on the \"Setup\" tab to get started!"
    static let hintInfoSwipeFeature = "You can swipe between shoes just by by swiping up or down on the shoe image in the \"Add Distance\" screen."
    static let hintInfoEmailHistoryFeature = "You can export your run history as a CSV file via email!  Just tap \"Email Data\" at the top left of the Run History screen."
    static let hintInfoHOFFeature = "You can now add shoes to the Hall of Fame section, so they don't crowd your active sneakers."
    static let hintInfoGraphAllShoesFeature = "You can tap the button at the bottom right of the graph to toggle between showing data for all active shoes or just the currently selected shoe."
    static let hintInfoYearlyHistoryFeature = "You can see yearly distances in the History view. The shoes tracked will match what the graph tracks."
    
    let hintDictionary = [
        hintStravaFeature : hintInfoStravaFeature,
        hintSwipeFeature : hintInfoSwipeFeature,
        hintEmailHistoryFeature : hintInfoEmailHistoryFeature,
        hintHOFFeature : hintInfoHOFFeature,
        hintGraphAllShoesFeature : hintInfoGraphAllShoesFeature,
        hintYearlyHistoryFeature : hintInfoYearlyHistoryFeature
    ]
    
    let allHintKeys = [hintSwipeFeature, hintStravaFeature, hintHOFFeature, hintGraphAllShoesFeature, hintEmailHistoryFeature, hintYearlyHistoryFeature]
    
    let completedHints: [String] = UserDefaults.standard.array(forKey: completedHintsKey) as? [String] ?? []
    
    func hintMessage() -> String? {
        guard let hintKey = currentHintKey() else {
            return nil
        }
        return hintDictionary[hintKey]
    }
    
    func completeHint() {
        guard let hintKey = currentHintKey() else {
            return
        }
        var newCompletedHints = completedHints
        newCompletedHints.append(hintKey)
        UserDefaults.standard.setValue(newCompletedHints, forKey: FTUHintManager.completedHintsKey)
    }
    
    private func currentHintKey() -> String? {
        let availableHints = allHintKeys.reduce([String]()) { partialResult, hint in
            if completedHints.contains(hint) == false {
                return partialResult + [hint]
            }
            return partialResult
        }
        return availableHints.first
    }
}
