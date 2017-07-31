//
//  ViewController.swift
//  ClassicPhotos
//
//  Created by Ke Ma on 31/07/2017.
//  Copyright © 2017 Ke Ma. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string: "http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ViewController: UITableViewController {
  
  lazy var photos = NSDictionary(contentsOf: dataSourceURL!)!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Classic Photos"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
    let rowKey = photos.allKeys[indexPath.row] as! String
    
    var image : UIImage?
    if let imageURL = URL(string: photos[rowKey] as! String),
    let imageData = NSData(contentsOf: imageURL) {
      let unfilteredImage = UIImage(data: imageData as Data)
      image = self.applySepiaFilter(unfilteredImage!)
    }
    
    // Configure the cell...
    cell.textLabel?.text = rowKey
    if image != nil {
      cell.imageView?.image = image!
    }
    return cell
  }

  func applySepiaFilter(_ image: UIImage) -> UIImage?
  {
    let inputImage = CIImage(data: UIImagePNGRepresentation(image)!)
    let context = CIContext(options: nil)
    let filter = CIFilter(name: "CISepiaTone")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter?.setValue(0.8, forKey: "inputIntensity")
    if let outputImage = filter?.outputImage {
      let outImage = context.createCGImage(outputImage, from: outputImage.extent)
      return UIImage(cgImage: outImage!)
    }
    return nil
  }

}

