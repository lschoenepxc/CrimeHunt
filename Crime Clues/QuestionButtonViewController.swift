import UIKit

class QuestionButtonViewController: QuestionViewController {
    
    // MARK: - UI Properties

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Properties
    var selectedAnswer: Int? // Speichert die gewählte Antwort
    
    var countTries = 0 // Speichert
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Submit-Button initial deaktivieren
        submitButton.isEnabled = false
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
        markAnswer(selectedIndex: 0)
    }
    
    @IBAction func answer2Pressed(_ sender: Any) {
        
        markAnswer(selectedIndex: 1)
    }
    
    @IBAction func answer3Pressed(_ sender: Any) {
        
        markAnswer(selectedIndex: 2)
    }

    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        // Überprüfe, ob die Antwort korrekt ist
        guard let selectedAnswer = selectedAnswer else { return }
        countTries += 1
                
        if selectedAnswer == quiz?.correctAnswerIndex {
            // Antwort ist richtig -> Zeige Popup und schließe View nach Bestätigung
            showAlert(isCorrect: true, count: countTries)
        } else {
            // Antwort ist falsch -> Zeige Popup
            showAlert(isCorrect: false, count: countTries)
        }
    }
    
    // MARK: - Helper Methods
    
    func markAnswer(selectedIndex: Int) {
        // Setze die gewählte Antwort
        selectedAnswer = selectedIndex
        
        // Hebe die gewählte Antwort hervor (z.B. durch Ändern der Hintergrundfarbe)
        resetButtonStyles() // Setze zuerst alle Buttons zurück
        switch selectedIndex {
        case 0:
            button1.backgroundColor = UIColor(named: "DarkColor")
        case 1:
            button2.backgroundColor = UIColor(named: "DarkColor")
        case 2:
            button3.backgroundColor = UIColor(named: "DarkColor")
        default:
            break
        }
        
        // Aktivere den Submit-Button, sobald eine Antwort gewählt wurde
        submitButton.isEnabled = true
    }
    
    func resetButtonStyles() {
        // Setze die Farben aller Buttons zurück
        button1.backgroundColor = .clear
        button2.backgroundColor = .clear
        button3.backgroundColor = .clear
    }
    
    func showAlert(isCorrect: Bool, count: Int) {
        // 20 Punkte, wenn beim ersten Mal antworten richtig
        // 10 Punkte, wenn beim zweiten Mal antworten rchtig
        // 0 Punkte, wenn beim dritten Mal antworten richtig
        
        let score = 30 - count*10
        let title = isCorrect ? "Richtige Antwort!" : "Falsche Antwort"
        let message = isCorrect ? "Gut gemacht! Du erhältst \(score) Punkte und hast neue Indizien freigeschaltet." : "Keine Sorge! Du hast noch eine  weitere Chance."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if isCorrect {
            // Wenn die Antwort richtig ist, schließe die View
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                if let presentingVC = self.presentingViewController as? HuntViewController {
                    presentingVC.receiveResult(answerScore: score)
                }
                // Schließe die View
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
        } else {
            // Bei falscher Antwort bleibt die View offen
            let retryAction = UIAlertAction(title: "Erneut versuchen", style: .default, handler: nil)
            alert.addAction(retryAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
