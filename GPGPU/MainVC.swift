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
        resultTextView.text += sumElements(arrayOfNumbers: array)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GenerateArrayVC {
            vc.onClose = { [weak self] vc in
                self?.array = (0..<vc.countOfElements).map { _ in (self?.random(from: vc.intervalFrom,
                                                                                to: vc.intervalTo))! }
                self?.generateArrayButton.setTitle("Массив сгенерирован", for: .normal)
            }
        }
    }
    
    func random(from: Int, to: Int) -> DataType {
        let randomNumber = Int(arc4random_uniform(UInt32(to + from))) - from
        return DataType(randomNumber)
    }
}
