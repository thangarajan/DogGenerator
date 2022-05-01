//
//  DGHomeViewController.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 30/04/22.
//

import UIKit

let plistName = "Data"

class DGHomeViewController: UIViewController {

    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var recentButton: UIButton!
    //var cache: LRUCache<String, Any>?
    var cache: CacheLRU<Int, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DGPlistManager.shared.start(plistNames: [plistName], logging: true)
        self.setUpButton(generateButton)
        self.setUpButton(recentButton)
        cache = CacheLRU(capacity: 20)
        self.updateLocalCache()
    }
    
    func updateLocalCache() {
        if let keys = DGPlistManager.shared.getAllKeys(inPlistWithName: plistName) {
            for key in keys {
                DGPlistManager.shared.getValue(for: key, fromPlistWithName: plistName) { result, error in
                    if error == nil {
                        self.cache?.setValue(result as Any, for: Int(key) ?? 0)
                    }
                }
            }
        }
    }
    
    func setUpButton(_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func recentButtonAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DGRecentDogsViewController") as? DGRecentDogsViewController
        vc?.viewModel = DGRecentViewModel(self.cache)
        self.navigationController?.show(vc!, sender: nil)
    }
    
    @IBAction func generateButtonAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DGDogGeneratedViewController") as? DGDogGeneratedViewController
        vc?.viewModel = DGGenerateViewModel(self.cache)
        self.navigationController?.show(vc!, sender: nil)
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
}

extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
}
