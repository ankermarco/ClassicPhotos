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
  
  var photos = [PhotoRecord]()
  let pendingOperations = PendingOperations()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Classic Photos"
    self.fetchAllPhotos()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func fetchAllPhotos()
  {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    let request = URLRequest(url: dataSourceURL!)
    
    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if data != nil
      {
        let datasourceDictionary = try! PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as! [AnyHashable : Any]
        for (key, value) in datasourceDictionary
        {
          let name = key as? String
          let url = URL(string: value as! String)
          
          if name != nil
          && url != nil
          {
            let photoRecord = PhotoRecord(name: name!, url: url!)
            self.photos.append(photoRecord)
          }// end inner if
        }// end for
      }// end outer if
      
      self.tableView.reloadData()
      
      if error != nil
      {
        let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
      }
    }
    dataTask.resume()
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    
  }
  private func startDownloadOperation(_ photoRecord: PhotoRecord, indexPath: IndexPath)
  {
    if pendingOperations.downloadInProgress[indexPath] != nil { return }
    
    let downloader = ImageDownloader(photoRecord)
    downloader.completionBlock = {
      if downloader.isCancelled { return }
      DispatchQueue.main.async {
        self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
    
    pendingOperations.downloadQueue.addOperation(downloader)
  }
  
  private func startFiltrationOperation(_ photoRecord: PhotoRecord, indexPath: IndexPath)
  {
    if pendingOperations.filtrationInProgress[indexPath] != nil { return }
    
    let filtration = ImageFiltration(photoRecord)
    filtration.completionBlock = {
      if filtration.isCancelled { return }
      DispatchQueue.main.async {
        self.pendingOperations.filtrationInProgress.removeValue(forKey: indexPath)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
    
    pendingOperations.filtrationQueue.addOperation(filtration)
  }
  
  private func startPendingOperations(_ photoRecord: PhotoRecord, indexPath: IndexPath)
  {
    switch photoRecord.status {
    case .New:
      self.startDownloadOperation(photoRecord, indexPath: indexPath)
    case .Downloaded:
      self.startFiltrationOperation(photoRecord, indexPath: indexPath)
    default:
      print("Do nothing")
    }
  }
  
  // MARK - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

    if cell.accessoryView == nil
    {
      cell.accessoryView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }
    
    let activityIndicator = cell.accessoryView as! UIActivityIndicatorView
    
    switch photos[indexPath.row].status {
    case .New, .Downloaded:
      activityIndicator.startAnimating()
      self.startPendingOperations(photos[indexPath.row], indexPath: indexPath)
    case .Failed:
      activityIndicator.stopAnimating()
      cell.textLabel?.text = "Failed to download"
    case .Filtered:
      activityIndicator.stopAnimating()
    }
    
    // Configure the cell...
    cell.textLabel?.text = photos[indexPath.row].name
    cell.imageView?.image = photos[indexPath.row].image

    return cell
  }
}

