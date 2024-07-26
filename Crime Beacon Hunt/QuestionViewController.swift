//
//  QuestionViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 26.06.24.
//

import UIKit

class QuestionViewController: UIViewController {
    
    // Abstract Class: not used directly
    /**
     Everything inside this ViewController will be required by it's children ButtonVC, PickerVC, TableVC.
     Therefore we just write it once and will be inherited by them.
     */
    
    // MARK: - UI Properties
    
    @IBOutlet weak var timecodeLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    // quiz data
    var quiz: QuizQuestion?
    var questionNo: Int?
    // timer
    var seconds = 0 // Variable will hold a starting value of seconds
    var timer = Timer() // // Used for on screen time display
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1.) change image accoring No
        if let no = questionNo {
            let imageName = "planet\(no)"
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        // 2.) show headline and question
        questionTitleLabel.text = "Quiz No: \(questionNo ?? 0)"
        questionTextView.text = quiz?.question
        
        // 3.) set up (local quiz) timer
        timecodeLabel.text = "00:00:00"
        seconds = 0 // better reset at each appearance
        startTimer()
    }
    
    // MARK: - Data Entry
    
    func question(_ quiz: QuizQuestion, questionNo: Int) {
        
        print("Received Quiz: \(quiz.question)")
        
        self.quiz = quiz
        self.questionNo = questionNo
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - User Action
    
    @IBAction func surrenderButtonPressed(_ sender: Any) {
        
        stopTimer()
        
        if let presentingVC = self.presentingViewController as? HuntViewController {
            
            presentingVC.receiveResult(answer: nil) // send result to main VC
        }
        
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Timer
    // this is copy & pasted code - there is of course a better solution, but for now…
    
    func startTimer() {
        // timer calls updateTimer function every second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HuntViewController.updateTimer)), userInfo: nil, repeats: true)
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
    
    // Encapsulate all important data as answer
    func wrapAnswer(number: Int?) -> QuizAnswer? {
        
        // number of the quiz, which index of the given options have been selected, how long the quiz took place
        // don't get confused with "questionNo ?? 0" - it's an optional at beginning, we provide a default just in case
        let answer = QuizAnswer(quizNo: questionNo ?? 0, answerIndex: number ?? 0, quizTime: seconds)
        
        return answer
    }

}
