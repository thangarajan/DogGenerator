//
//  DGRecentDogsViewController.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 30/04/22.
//

import UIKit

class DGRecentDogsViewController: UIViewController {
    var scrollView: UIScrollView!
    @IBOutlet weak var clearDogsButton: UIButton!

    /// ViewModel object
    var viewModel: DGRecentViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "My Recently Generated Dogs!"
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 120, width: viewModel.screenWidth, height: viewModel.imageHeight))
        self.scrollView.bounces = false
        self.view.addSubview(self.scrollView)
        self.viewModel.setUpButton(clearDogsButton)
        self.loadScrollViewItems()
    }
    
    func loadScrollViewItems() {
        if let images = self.viewModel.getCachedItems() {
            for i in 0..<images.count {
                var x_Value: CGFloat = 0
                if i == 0 {
                    x_Value = 0
                } else {
                    x_Value = (CGFloat(i) * viewModel.screenWidth) - CGFloat(10)
                }
                let frame = CGRect(x: x_Value, y: 0, width: viewModel.screenWidth - 20, height: viewModel.imageHeight)
                let imageView = UIImageView(frame: frame)
                imageView.contentMode = .scaleToFill
                imageView.image = images[i]
                self.scrollView.addSubview(imageView)
            }
            self.scrollView.contentSize = CGSize(width: CGFloat(images.count) * viewModel.screenWidth, height: viewModel.imageHeight)
        }
    }
    
    @IBAction func clearDogsButtonAction(_ sender: UIButton) {
        self.viewModel.clearAllCaches()
        let subViews = self.scrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
    }

    open override var shouldAutorotate: Bool {
        return false
    }
}
