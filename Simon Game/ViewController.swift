//
//  ViewController.swift
//  Simon Game
//
//  Created by Gregory Orton on 3/2/17.
//  Copyright © 2017 ortonomy. All rights reserved.
//

import UIKit

fileprivate struct Game {
    var power: Bool
    var score: Int?
    var sequence: [Int]
    var sequenceCount: Int?
    var playerProgress: Int?
    var lastPress: Int?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var systemSaysLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreTextLabel: UILabel!
    @IBOutlet var colourButtons: [UIButton]!


    
    fileprivate var gameState: Game = Game(power:false,
                               score: nil,
                               sequence: [],
                               sequenceCount: nil,
                               playerProgress: nil,
                               lastPress: nil)
    
    /// kicks off the game, or kills it, depending on the state
    @IBAction func tapStart(_ sender: UIButton) {
        if !gameState.power {
            reset()
            gameState.power = true
            controlButton.setTitle("STOP",
                                   for: .normal)
            startGame()
            return
        }
        gameState.power = false
        controlButton.setTitle("START",
                               for: .normal)
        reset()
    }
    
    @IBAction func colourTap(_ sender: UIButton) {
        if gameState.playerProgress! < gameState.sequence.count {
            let passed = checkResult(sender.tag)
            if passed {
                gameState.playerProgress = gameState.playerProgress! + 1
                if gameState.playerProgress! == gameState.sequence.count {
                    setScore(gameState.sequence.count)
                    cycleGame()
                }
            } else {
                playerError()
            }
        }
    }
    
    func setScore (_ score: Int) -> Void {
        gameState.score = score
        displayScore(gameState.score!)
    }
    
    func displayScore (_ score: Int) -> Void {
        scoreLabel.text = String(score)
    }
   
    func checkResult(_ tag: Int) -> Bool {
        if tag - 1 == gameState.sequence[gameState.playerProgress!] {
            return true
        }
        return false
    }
    
    func playerError () -> Void {
        gameState.playerProgress = 0
        for button in colourButtons {
            button.isEnabled = false
        }
        sendMessage(message: "No, watch again...")
        showSequence()
    }
    
    /// Resets all game parameters
    func reset () {
        gameState.score = nil
        gameState.sequence = []
        gameState.playerProgress = nil
        gameState.sequenceCount = nil
        gameState.lastPress = nil
        scoreLabel.alpha = 0
        scoreLabel.text = "0"
        scoreTextLabel.alpha = 0
        for button in colourButtons {
            button.isEnabled = false
        }
        sendMessage(message: "Press start!")
    }
    
    /// Starts game including calling messaging and updating score
    func startGame () {
        cycleGame()
    }
    
    func cycleGame () -> Void {
        // set instructions
        sendMessage(message: "Watch me...")
        // get something to show
        extendSequence()
        // show it
        showSequence()
    }
    
    /// Updates the system message
    func sendMessage (message: String) {
        systemSaysLabel.text = message
    }
    
    /// Adds an additional item to the sequence the player must complete
    func extendSequence () -> Void {
        gameState.sequence.append(Int(arc4random_uniform(4)))
    }
    
    /// Returns latest button in sequence
    func getLatestButton () -> UIButton {
        return colourButtons[gameState.sequence[gameState.sequenceCount!]]
    }
    
    /// Transitions a UIButton to highlight state
    func highlightNextButton() -> Void {
        let button: UIButton = getLatestButton()
        print(button.tag)
        button.isEnabled = true
        UIView.transition(with: button,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            button.isHighlighted = true
                          },
                          completion: dimLastButton)
    }
    
    /// Transitions a UIButton back to default state and then to disabled
    func dimLastButton(_ : Bool) -> Void {
        let button: UIButton = getLatestButton()
        print(button.tag)
        UIView.transition(with: button,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            button.isHighlighted = false
                            button.isEnabled = false
                          },
                          completion: increaseSequenceCount)
    }
    
    func increaseSequenceCount(_: Bool) -> Void {
        gameState.sequenceCount = gameState.sequenceCount! + 1
        if gameState.sequenceCount! < gameState.sequence.count {
            highlightNextButton()
            return
        }
        // otherwise end the sequence
        endSequence()
    }
    
    /// Enables all buttons ready for player input
    func readyForPlayer () -> Void {
        for button in colourButtons {
            button.isEnabled = true
        }
        gameState.playerProgress = 0
        sendMessage(message: "Copy me...")
        UIView.transition(with: scoreLabel,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.scoreLabel.alpha = 1
                          },
                          completion: nil)
        UIView.transition(with: scoreTextLabel,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.scoreTextLabel.alpha = 1
                          },
                          completion: nil)
    }
    
    /// Displays the sequence for the user
    func showSequence() {
        if gameState.power {
            gameState.sequenceCount = 0
            // kickstart the sequence (this is a function that will get called repeatedly until it exhausts the sequence
            highlightNextButton()
        }
    }
    
    func endSequence () -> Void {
        readyForPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlButton.layer.cornerRadius = 5
        for button in colourButtons {
            button.isEnabled = false
        }
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


}

