//
//  PNSViewController.swift
//  POP Nutshell
//
//  Created by Patrick Bellot, inspired by CodeWithChris https://www.youtube.com/playlist?list=PLMRqhzcHGw1aLoz4pM_Mg2TewmJcMg9uaon 4/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit
import CoreData

private let cellIdentifier = "VideoCell"

class PNSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest!
    var selectedVideo: Video!
//    var fetchedResultsController: NSFetchedResultsController!
    var asyncFetchRequest: NSAsynchronousFetchRequest!
    var videos: [Video]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(NSManagedObject)
        
//        let fetchedResultsController: NSFetchedResultsController = {
//            let videoFetchRequest = NSFetchRequest(entityName: "Video")
//            let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: false)
//            let publishedSortDescriptor = NSSortDescriptor(key: "publishedAt", ascending: true)
//            let iDSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
//            let thumbnailSortDescriptor = NSSortDescriptor(key: "thumbnail.url", ascending: false)
//            videoFetchRequest.sortDescriptors = [titleSortDescriptor,
//                                                 publishedSortDescriptor,
//                                                 iDSortDescriptor,
//                                                 thumbnailSortDescriptor]
//            
//            let frc = NSFetchedResultsController(
//                fetchRequest: videoFetchRequest,
//                managedObjectContext: self.context,
//                sectionNameKeyPath: "thumbnail.url",
//                cacheName: nil)
//            
//            frc.delegate = self
//            
//            return frc
//        }()
        
        fetchRequest = NSFetchRequest(entityName: "Video")
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
                self.videos = result.finalResult as! [Video]
                self.tableView.reloadData()
        }
        do {
            try coreDataStack.managedObjectContext.executeRequest(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func configureCell(cell: VideoCell, indexPath: NSIndexPath){
        let video = videos[indexPath.row]
        cell.titleLabel!.text = video.title
        _ = video.id
        
        let imageURL = NSURL(string: (video.thumbnails?.url)!)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            cell.videoThumbnailUrl!.image = UIImage(data: imageData)
        }
    }

    // Tableview Delegate methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Get the width of the screen to calculate the height of the row
        return (self.view.frame.size.width / 480) * 360
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let numberOfRowsInSection = fetchedResultsController.sections?[section].numberOfObjects
//        return numberOfRowsInSection!
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VideoCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let favoriteButton = UITableViewRowAction(style: .Normal, title: "Add to Favorites") { action, index in
            print("favorite button tapped")
            
            let favoritedVideo = Video()
                if favoritedVideo.isFavorite == true {
                    let alert = UIAlertController(title: "Saved", message: "Video added to Favorites", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in })
                    alert.addAction(okAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
            }
            
            self.coreDataStack.saveContext()
            tableView.setEditing(false, animated: true)
    }
        favoriteButton.backgroundColor = UIColor.blueColor()
        
        let shareButton = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
            
            let sharedVideo = Video()
                if sharedVideo.isShared == true {
                    let activityViewController = UIActivityViewController(activityItems: [sharedVideo], applicationActivities: nil)
                    self.presentViewController(activityViewController, animated: true, completion: nil)
            }
            
            tableView.setEditing(false, animated: true)
        }
        shareButton.backgroundColor = UIColor.lightGrayColor()
        
        return [favoriteButton, shareButton]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Take note of which video the user selected
        selectedVideo = videos[indexPath.row]
        // Call the segue
        performSegueWithIdentifier("goToDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the reference to the destination view controller
        let detailViewController = segue.destinationViewController as! PNSVideoDetailViewController
        
        // Set the selected video property of the destination view controller
        detailViewController.selectedVideo = self.selectedVideo
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! VideoCell
                configureCell(cell, indexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
            case .Insert:
                tableView.insertSections(indexSet, withRowAnimation: .Automatic)
            case .Delete:
                tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default :
            break
        }
    }
}
