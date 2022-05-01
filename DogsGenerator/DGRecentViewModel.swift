//
//  DGRecentViewModel.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 30/04/22.
//

import UIKit

class DGRecentViewModel: NSObject {
    
    var cache: CacheLRU<Int, Any>?
    let screenWidth = UIScreen.main.bounds.width
    let imageHeight: CGFloat = 300
    
    override init() {
        super.init()
    }
    
    convenience init(_ cache: CacheLRU<Int, Any>?) {
        self.init()
        self.cache = cache
    }
    
    func setUpButton(_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    /// Reading saved Images datas from the LRU
    /// - Returns: Returs the array of UIImage
    func getCachedItems() -> [UIImage]? {
        var cachedImages = [UIImage]()
        if let data = self.cache?.nodesDict {
            let allKeys = data.keys.sorted().reversed()
            for key in allKeys {
                print(key)
                if let imagePath = self.cache?.getValue(for: key) as? String, let image = getSavedImage(named: imagePath) {
                    cachedImages.append(image)
                }
            }
        }
        return cachedImages
    }
    
    
    /// Clearing all datas
    func clearAllCaches() {
        if let nCache = cache {
            nCache.nodesDict.removeAll()
            self.clearAllFiles()
            self.clearPlistData()
        }
    }
    
    /// Clearing Plsit data from Local filepath
    func clearPlistData() {
        DGPlistManager.shared.removeAllKeyValuePairs(fromPlistWithName: plistName) { (err) in
          if err == nil {
            print("-------------> Successfully removed all Key-Value pairs from '\(plistName).plist'")
          }
        }
    }
    
    /// Clearing the all UIImage local file path
    func clearAllFiles() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!        
        print("Directory: \(paths)")
        
        do
        {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            
            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Getting saved UIImage
    /// - Parameter named: image last path
    /// - Returns: returns the local UIImage
    func getSavedImage(named: String) -> UIImage? {
        if let filePath = fileInDocumentsDirectory(filename: named) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
    
    /// getting local uiimage file path from Last file path
    /// - Parameter filename: image last path
    /// - Returns: returns the local file path
    func fileInDocumentsDirectory(filename: String) -> String? {
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        let filePath = directory.appendingPathComponent(filename)
        return filePath?.path
    }
}
