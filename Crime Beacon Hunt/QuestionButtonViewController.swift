//
//  QuestionButtonViewController.swift
//  Universe Hunt
//
//  Created by Heizo Schulze on 26.06.24.
//

import UIKit

class QuestionButtonViewController: QuestionViewController {
    
    // MARK: - UI Properties

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        button1.setTitle(quiz?.answers[0], for: .normal) // first entry
        button2.setTitle(quiz?.answers[1], for: .normal) // second entry
        button3.setTitle(quiz?.answers[2], for: .normal) // third entry
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
    
    @IBAction func answer1Pressed(_ sender: Any) {
        
        if let presentingVC = self.presentingViewController as? HuntViewController {
            
            let answer = wrapAnswer(number: 0) // remember: it's a function we inherited
            presentingVC.receiveResult(answer: answer) // send result to main VC
        }
        
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answer2Pressed(_ sender: Any) {
        
        if let presentingVC = self.presentingViewController as? HuntViewController {
            
            let answer = wrapAnswer(number: 1) // remember: it's a function we inherited
            presentingVC.receiveResult(answer: answer) // send result to main VC
        }
        
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answer3Pressed(_ sender: Any) {
        
        if let presentingVC = self.presentingViewController as? HuntViewController {
            
            let answer = wrapAnswer(number: 2) // remember: it's a function we inherited
            presentingVC.receiveResult(answer: answer) // send result to main VC
        }
        
        // this viewController closes itself
        dismiss(animated: true, completion: nil)
    }

}
