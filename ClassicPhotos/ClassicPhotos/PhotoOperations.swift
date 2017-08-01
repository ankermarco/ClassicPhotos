//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Ke Ma on 31/07/2017.
//  Copyright © 2017 Ke Ma. All rights reserved.
//

import UIKit
import CoreImage

enum PhotoStatus
{
  case New, Downloaded, Filtered, Failed
}

class PhotoRecord
{
  let name: String
  let url: URL
  var status = PhotoStatus.New
  var image = UIImage(named: "Placeholder")
  
  init(name: String, url: URL)
  {
    self.name = name
    self.url = url
  }
}

class PendingOperations
{
  lazy var downloadInProgress = [IndexPath: Operation]()
  lazy var downloadQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.name = "Download Queue"
    return queue
  }()
  
  lazy var filtrationInProgress = [IndexPath: Operation]()
  lazy var filtrationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.name = "Filtration Queue"
    
    return queue
  }()
}

class ImageDownloader: Operation
{
  let photoRecord: PhotoRecord
  
  init(_ photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main() {
    if self.isCancelled { return }
    
    let imageData = NSData(contentsOf: photoRecord.url)
    
    if self.isCancelled { return }
    
    if (imageData?.length)! > 0
    {
      photoRecord.status = .Downloaded
      photoRecord.image = UIImage(data: imageData! as Data)
    }
    else
    {
      photoRecord.status = .Failed
      photoRecord.image = UIImage(named: "Failed")
    }
  }
}

class ImageFiltration: Operation
{
  let photoRecord: PhotoRecord
  
  init(_ photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main() {
    if self.isCancelled { return }
    
    if self.photoRecord.status == .Failed { return }
      
    if let filteredImage = self.applySepiaFilter(self.photoRecord.image!)
    {
      self.photoRecord.status = .Filtered
      self.photoRecord.image = filteredImage
    }
  }
  
  func applySepiaFilter(_ image:UIImage) -> UIImage?
  {
    let inputImage = CIImage(data: UIImagePNGRepresentation(image)!)
    
    if self.isCancelled { return nil }
    
    let context = CIContext(options: nil)
    let filter = CIFilter(name: "CISepiaTone")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter?.setValue(0.8, forKey: "inputIntensity")
    let outputImage = filter?.outputImage
    
    if self.isCancelled { return nil }
    
    let outImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
    let returnImage = UIImage(cgImage: outImage!)
    return returnImage
  }
}


