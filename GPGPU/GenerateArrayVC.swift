import UIKit

class GenerateArrayVC: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var countOfElementsTextField: UITextField!
    @IBOutlet var intervalFromTextField: UITextField!
    @IBOutlet var intervalToTextField: UITextField!
    @IBOutlet var generateArrayButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var powerTableView: UITableView!
    
    var countOfElements: Int!
    var intervalFrom: Int!
    var intervalTo: Int!
    
    var onClose: (([DataType]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        powerTableView.isHidden = true
        generateArrayButton.layer.borderWidth = 1
        generateArrayButton.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
        containerView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(closeKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapRecognizer)
        progressView.isHidden = true
        
        powerTableView.layer.borderWidth = 1
        powerTableView.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
        powerTableView.layer.cornerRadius = 10
        countOfElementsTextField.addTarget(self, action: #selector(openPowerTableView), for: .touchDown)
    }
    
    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    func openPowerTableView() {
        powerTableView.isHidden = false
    }
    
    func close() {
        progressView.isHidden = false
        progressView.progress = 0
        countOfElements = Int(countOfElementsTextField.text!) ?? 0
        intervalFrom = Int(intervalFromTextField.text!) ?? 0
        intervalTo = Int(intervalToTextField.text!) ?? 0
        var array = [DataType]()
        let tick = countOfElements / 100 > 0 ? countOfElements / 100 : 1
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
        let randomNumber = Int(arc4random_uniform(UInt32(to))) + from
        return DataType(randomNumber)
    }
    
    @IBAction func tapCloseButton(_ sender: UIButton) {
        close()
    }
}

extension GenerateArrayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        countOfElementsTextField.text = "\(pow(2, indexPath.row))"
        tableView.isHidden = true
    }
}

extension GenerateArrayVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "powerCell", for: indexPath)
        if let cell = cell as? PowerTableViewCell {
            cell.valueLabel.text = "\(pow(2, indexPath.row))"
        }
        return cell
    }
    
    
}
