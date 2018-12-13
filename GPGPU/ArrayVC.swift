import UIKit

class ArrayVC: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cleararrayButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    var onClose: ((Bool) -> Void)?
    var array: [DataType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleararrayButton.layer.borderWidth = 1
        cleararrayButton.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = #colorLiteral(red: 0.4260271237, green: 0.2024844847, blue: 1, alpha: 1).cgColor
    }
    
    func close(clear: Bool) {
        onClose?(clear)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapClearArrayButton(_ sender: UIButton) {
        close(clear: true)
    }
    
    @IBAction func tapCloseButton(_ sender: UIButton) {
        close(clear: false)
    }
}
extension ArrayVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ArrayElementCell {
            cell.textLabel.text = "\(indexPath.row + 1): \(array[indexPath.row])"
        }
    }
}

extension ArrayVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
}
