import UIKit

class GenerateArrayVC: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var countOfElementsTextField: UITextField!
    @IBOutlet var intervalFromTextField: UITextField!
    @IBOutlet var intervalToTextField: UITextField!
    @IBOutlet var generateArrayButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    
    var countOfElements: Int!
    var intervalFrom: Int!
    var intervalTo: Int!
    
    var onClose: (([DataType]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateArrayButton.layer.borderWidth = 1
        generateArrayButton.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
        containerView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(closeKeyboard))
        containerView.addGestureRecognizer(tapRecognizer)
        progressView.isHidden = true
    }
    
    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func close() {
        progressView.isHidden = false
        progressView.progress = 0
        countOfElements = Int(countOfElementsTextField.text!) ?? 0
        intervalFrom = Int(intervalFromTextField.text!) ?? 0
        intervalTo = Int(intervalToTextField.text!) ?? 0
        var array = [DataType]()
        let tick = countOfElements / 100
        DispatchQueue.global().async {
            for index in stride(from: 0, to: self.countOfElements, by: 1) {
                array.append(self.random(from: self.intervalFrom, to: self.intervalTo))
                if index % tick == 0 {
                    DispatchQueue.main.async {
                        self.progressView.progress = Float(index) / Float(self.countOfElements)
                    }
                }
            }
            DispatchQueue.main.async {
                self.onClose?(array)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func random(from: Int, to: Int) -> DataType {
        let randomNumber = Int(arc4random_uniform(UInt32(to))) + from // fix me!!!
        return DataType(randomNumber)
    }
    
    @IBAction func tapCloseButton(_ sender: UIButton) {
        close()
    }
}
