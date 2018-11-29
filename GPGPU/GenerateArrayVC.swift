//
//  GenerateArrayVC.swift
//  GPGPU
//
//  Created by kathelyss on 29/11/2018.
//  Copyright © 2018 Екатерина Рыжова. All rights reserved.
//

import UIKit

class GenerateArrayVC: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var countOfElementsTextField: UITextField!
    @IBOutlet var intervalFromTextField: UITextField!
    @IBOutlet var intervalToTextField: UITextField!
    var countOfElements: Int!
    var intervalFrom: Int!
    var intervalTo: Int!
    
    var onClose: ((GenerateArrayVC) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(closeKeyboard))
        containerView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func close() {
        countOfElements = Int(countOfElementsTextField.text!) ?? 0
        intervalFrom = Int(intervalFromTextField.text!) ?? 0
        intervalTo = Int(intervalToTextField.text!) ?? 0
        onClose?(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCloseButton(_ sender: UIButton) {
        close()
    }
}
