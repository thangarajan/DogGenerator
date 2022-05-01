//
//  DGDogGeneratedViewController.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 30/04/22.
//

import UIKit

class DGDogGeneratedViewController: UIViewController {

    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    /// ViewModel object
    var viewModel: DGGenerateViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Generate Dogs!"
        self.activityIndicator.isHidden = true
        self.viewModel.setUpButton(generateButton)
    }
    
    @IBAction func generateButtonAction(_ sender: UIButton) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.generateButton.isEnabled = false
        self.viewModel.getRandomImage { image in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.generateButton.isEnabled = true
            if let nImage = image {
                self.imageView.image = nImage
            }
        }
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
