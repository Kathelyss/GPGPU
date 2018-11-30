//
//  ViewController.swift
//  GPGPU
//
//  Created by kathelyss on 27/10/2018.
//  Copyright © 2018 Екатерина Рыжова. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet var resultTextView: UITextView!
    @IBOutlet var generateArrayButton: UIButton!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    var array: [DataType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTextView.text = ""
        sortButton.isEnabled = false
        filterButton.isEnabled = false
    }
    
    @IBAction func tapSumButton(_ sender: UIButton) {
        if array.isEmpty {
            let ac = UIAlertController(title: "Так не пойдёт", message: "Сгенерируйте массив", preferredStyle: .alert)
            let action = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
            ac.addAction(action)
            self.present(ac, animated: true, completion: nil)
        } else {
            resultTextView.text += sumElements(arrayOfNumbers: array)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GenerateArrayVC {
            vc.onClose = { [weak self] array in
                guard let self = self else { print("Error! No self line \(#line)")
                    return
                }
                self.array = array
                self.generateArrayButton.setTitle("Посмотреть массив", for: .normal)
            }
        } else if let vc = segue.destination as? ArrayVC {
            vc.array = array
            vc.onClose = { [weak self] clear in
                if clear {
                    self?.array = []
                    self?.generateArrayButton.setTitle("Сгенерировать массив", for: .normal)
                }
            }
        }
    }
    
    @IBAction func tapGenerateArrayButton(_ sender: UIButton) {
        if array.isEmpty {
            performSegue(withIdentifier: "ToGenerateArray", sender: self)
        } else {
            performSegue(withIdentifier: "ToArrayDetails", sender: self)
        }
    }
    
    
}
