//
//  HuntViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 20.06.24.
//

import UIKit

class MainVC: UIViewController {
    
    // MARK: - UI Properties
    
    @IBOutlet weak var timecodeLabel: UILabel!
    
    
    @IBOutlet weak var beaconView: UIView!
    @IBOutlet weak var investigationView: UIView!
    
    // MARK: - Properties
    // Beacon
    
    // Timer
    var seconds = 0 // Variable will hold a starting value of seconds
    var timer = Timer() // // Used for on screen time display
    
    // Game Data
    var questions: [QuizQuestion]? // optional array of questions, not existent at start
    var answers = [QuizAnswer]() // empty array
    var presentedQuizNo = 0
    
    // keep track of current index for orte and quiz questions (both shuffled lists)
    var currentIndex = 0
    
    var orte: [Ort]? // optional array of orte, not existent at start
    
    // Get to hold the FinishVC
    weak var delegate: CloseDelegate? // required to close multiple VC
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // 2.) load questions from file Data
        if let questions = loadQuestionsFromPlist() {
            
            // uncomment to check loaded data in log
            /*
             for question in questions {
             print("Frage: \(question.question)")
             print("Antworten: \(question.answers)")
             print("Richtig: \(question.correctAnswerIndex)")
             }
             */
            
            self.questions = questions.shuffled()
        } else {
            fatalError("Could NOT load Content Dictionary!")
        }
        
        // 3.) load orte from file Orte
        if let orte = loadOrteFromPlist() {
                    
            // uncomment to check loaded data in log
            /*
                for ort in orte {
                print("OrtID: \(ort.ortID)")
                print("Name: \(ort.name)")
                print("Picture: \(ort.picture)")
                print("QuizNo: \(ort.quizNo)")
                print("Indizien: \(ort.indizien)")
                print("BeaconMajor: \(ort.beaconMajor)")
                print("BeaconMinor: \(ort.beaconMinor)")
                }
             */
            self.orte = orte.shuffled()
        } else {
            fatalError("Could NOT load Content Dictionary!")
        }
    }
    
    // MARK: - Start/Stop
    

    // MARK: - Navigation (send data & full screen)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // let no = presentedQuizNo // has been set with quiz button tag beforehand
        let no = currentIndex
        
        // MARK: Send Quiz to any QuestionVC
        if let destinationVC = segue.destination as? QuestionViewController {
            
            // 1.) send data
            // because tag are from 1-9 and the array is from 0-8
            //let quiz = questions![no - 1] // ! means we are sure not to have an optional value here
            let quiz = questions![no] // ! to avoid error without beacons
            destinationVC.question(quiz, questionNo: no) // this is the same as the tag number
            
            // 2.) full screen
            destinationVC.modalPresentationStyle = .fullScreen
        }
        
        // MARK: Send Game Data to FinishViewController
        if let finishVC = segue.destination as? FinishViewController {
            
            finishVC.delegate = self
            
            // 1.) send data
            let timeText = timeString(time: Double(seconds))
            let time = seconds
            let score = calculateScore()
            finishVC.receiveGameData(timeString: timeText, seconds: time, score: score)
            
            // 2.) full screen
            finishVC.modalPresentationStyle = .fullScreen
        }
    }
    
    // MARK: - Data Entry after Quiz
    
    func receiveResult(answer: QuizAnswer?) {
        
        if let result = answer {
            print("Received answer: \(result)")
        } else {
            print("Player surrendered QUIZ No \(presentedQuizNo)")
        }
        
        // put into a seprate function for clarity
        storeResult(answer: answer)
    }
    
    func storeResult(answer: QuizAnswer?) {
        
        if let storeAnswer = answer { // answer given
            
            // store result
            answers.append(storeAnswer)
            
        } else { // no answer given: surrendered
            // do nothing
        }
        
        // count up the current Index
        currentIndex = currentIndex + 1
        print(currentIndex)
        
        updateBeaconScrollView()
    }
    
    // override in BeaconVC
    func updateBeaconScrollView() {
        print("Trying to override")
    }
    
    // TODO: calculate your score
    func calculateScore() -> Int {
        
        var score = 0
        
        for answer in answers {
            
            //let quizNo = answer.quizNo - 1 // adjust to index 0 of array
            let quizNo = answer.quizNo
            
            guard let correctIndex = questions?[quizNo].correctAnswerIndex else {
                print("Nil data - please check questions no: \(answer.quizNo)")
                return 0
            }
            let correct = answer.answerIndex == correctIndex - 1 // adjust to index 0 of array
            
            print("Calculate Score Question: \(answer.quizNo)")
            print("Correct Answer: \(correctIndex) Selected Answer \(answer.answerIndex)")
            
            if correct {
                if answer.quizTime <= 15 {
                    score = score + 10 * 4 // factor 4
                } else if answer.quizTime <= 30 {
                    score = score + 10 * 3 // factor 3
                } else if answer.quizTime <= 45 {
                    score = score + 10 * 2 // factor 2
                } else {
                    score = score + 10
                }
            } // otherwise do not increase score
        }
        
        return score
    }
    
    // MARK: - User Action
    
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            beaconView.alpha = 1
            investigationView.alpha = 0
        }
        else {
            beaconView.alpha = 0
            investigationView.alpha = 1
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        // close this VC (data will be passed in func prepare(for segue…)
        performSegue(withIdentifier: "finishSegue", sender: nil)
    }
    
    // MARK: - Timer
    
    func startTimer() {
        // timer calls updateTimer function every second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HuntViewController.updateTimer)), userInfo: nil, repeats: true)
        beaconView.alpha = 1
        investigationView.alpha = 0
    }
    
    @objc func updateTimer() { // needs the special @objc mark because of Objective C source code
        // Increment the seconds on each call by one
        seconds += 1
        // Update the label afterwards
        timecodeLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    // removes timer and resets seconds
    func stopTimer() {
        timer.invalidate()
        seconds = 0
    }
    
    // MARK: - Helper
    
    // Conversion of time format into readable timecode string
    func timeString(time:TimeInterval) -> String {
        let hh = Int(time) / 3600
        let mm = Int(time) / 60 % 60
        let ss = Int(time) % 60
        let secondString = ss < 10 ? "0\(ss)" : "\(ss)"
        let minuteString = mm < 10 ? "0\(mm)" : "\(mm)"
        let hourString = hh < 10 ? "0\(hh)" : "\(hh)"
        return String(format:"\(hourString):\(minuteString):\(secondString)")
    }
    
    // MARK: - Loading Data
    
    // Loading data from Data.plist file
    func loadQuestionsFromPlist() -> [QuizQuestion]? {
        
        // make sure data is loaded properly
        guard let url = Bundle.main.url(forResource: "Data", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String:Any] else {
            return nil
        }
        
        // Our XML structure is build with a array at topmost level
        if let array = dict["questions"] as? Array<Dictionary<String, Any>> {
            var questions = [QuizQuestion]()
            
            // this array holds dictionaries
            for dict in array {
                
                // TODO: IMPORTANT if any of these will fail, loading will fail completely
                if let question = dict["Frage"] as? String,
                   let answers = dict["Antworten"] as? [String],
                   let correctAnswerIndex = dict["richtig"] as? Int {
                    let quizQuestion = QuizQuestion(question: question, answers: answers, correctAnswerIndex: correctAnswerIndex)
                    questions.append(quizQuestion)
                }
            }
            return questions
        } else {
            debugPrint("Could NOT read questions")
            return nil
        }
    }
    
    // Loading data from Data.plist file
    func loadOrteFromPlist() -> [Ort]? {
            
        // make sure data is loaded properly
        guard let url = Bundle.main.url(forResource: "Orte", withExtension: "plist"),
                let dict = NSDictionary(contentsOf: url) as? [String:Any] else {
            return nil
        }
            
        // Our XML structure is build with a array at topmost level
        if let array = dict["Orte"] as? Array<Dictionary<String, Any>> {
            var orte = [Ort]()
                
            // this array holds dictionaries
            for dict in array {
                    
                // TODO: IMPORTANT if any of these will fail, loading will fail completely
                if let ortID = dict["ortID"] as? Int,
                    let name = dict["name"] as? String,
                    let picture = dict["picture"] as? String,
                    let quizNo = dict["quizNo"] as? Int,
                    let indizien = dict["indizien"] as? [String],
                    let beaconMajor = dict["beaconMajor"] as? Int,
                    let beaconMinor = dict["beaconMinor"] as? Int {
                    let ort = Ort(ortID: ortID, name: name, picture: picture, quizNo: quizNo, indizien: indizien, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
                    orte.append(ort)
                }
            }
            return orte
        } else {
            debugPrint("Could NOT read orte")
            return nil
        }
    }
    
    // MARK: - UI Update Helper
    
    
}

// MARK: - CloseDelegate

extension MainVC: CloseDelegate {
    
    // secure close multiple VC at once
    func closeViewControllers() {
        
        // Dismiss the presented view controller first
        self.presentedViewController?.dismiss(animated: true, completion: {
            // Then dismiss the presenting view controller
            self.dismiss(animated: true, completion: nil)
        })
        
    }
}
