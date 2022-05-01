//
//  DGGenerateViewModel.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 30/04/22.
//

import UIKit

typealias Completion = (_ image: UIImage?) -> Void

class DGGenerateViewModel: NSObject {
    let randomDogGenerateURL = "https://dog.ceo/api/breeds/image/random"
    var completion: Completion?
    var cache: CacheLRU<Int, Any>?

    override init() {
        super.init()
    }
    
    convenience init(_ cache: CacheLRU<Int, Any>?) {
        self.init()
        self.cache = cache
    }
    
    /// Setup the button properites
    /// - Parameter button: UIButton Object
    func setUpButton(_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    
    /// Getting the dogs generator jsons
    /// - Parameter onCompletion: returns the DGDogModel
    func getImageUrl(onCompletion: @escaping (_ response: DGDogModel?) -> Void) {
        if let url = URL(string: randomDogGenerateURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                guard let data = data, error == nil else {
                    print(error?.localizedDescription as Any)
                    onCompletion(nil)
                    return
                }
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(DGDogModel.self, from: data)
                    onCompletion(responseModel)
                } catch let parseError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
            }.resume()
        }
    }
    
    /// Gfetting the random dogs image
    /// - Parameter onCompletion: returns the UIImage object
    func getRandomImage(onCompletion: @escaping Completion) {
        self.completion = onCompletion
        self.getImageUrl { response in
            if let model = response, let imageUrl = model.message {
                self.downloadImage(imageUrl, onCompletion: onCompletion)
            }
        }
    }
    
    /// Downloading the Image using Url
    /// - Parameters:
    ///   - imageUrl: URL object
    ///   - onCompletion: returns the UIImage object
    func downloadImage(_ imageUrl: String, onCompletion: @escaping Completion) {
        if let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data,
                          let image = UIImage(data: data) else {
                              onCompletion(nil)
                              return
                          }
                    self.saveImageIntoCache(image, url)
                    onCompletion(image)
                }
            }.resume()
        }
    }
    
    /// Saving image into Custom data structures
    /// - Parameters:
    ///   - image: UIImage object
    ///   - url: UIImage url
    func saveImageIntoCache(_ image: UIImage, _ url: URL) {
        if let _ = self.saveImage(image: image, fileName: url.lastPathComponent) {
            if let nCache = self.cache {
                let lastIndex = nCache.nodesDict.count + 1
                nCache.setValue(url.lastPathComponent, for: lastIndex)
            }
        }
    }
    
    /// Saving Image into local file path
    /// - Parameters:
    ///   - image: UIImage object
    ///   - fileName: UIImage file name
    /// - Returns: Returns original file path
    func saveImage(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        do {
            let filePath = directory.appendingPathComponent(fileName)
            try data.write(to: filePath!)
            return filePath?.path
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
