//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 1/26/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

/* 1 - Define constants */
let BASE_URL = "https://api.500px.com/v1"
let METHOD_NAME = "/photos/search"
let API_KEY = "YOUR_500px_API_WITHOUT_FU*CKING_YAHOO"

class ViewController: UIViewController {
 
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    
    @IBAction func touchRefreshButton(sender: AnyObject) {
        getImageFrom500px()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getImageFrom500px() {
        
        /* 2 - API method arguments */
        let methodArguments = [
            "term": "sleeping in a library",
            "consumer_key": API_KEY
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + METHOD_NAME + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        println(url)
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                if let photoArray = parsedResult.valueForKey("photos") as? NSArray {
                        
                        /* 6 - Grab a single, random image */
                        if photoArray.count > 0 {
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                            let photoDictionary = photoArray[randomPhotoIndex] as! [String: AnyObject]

                            /* 7 - Get the image url and title */
                            let photoTitle = photoDictionary["title"] as? String
                            let imageUrlString = photoDictionary["image_url"] as? String
                            let imageURL = NSURL(string: imageUrlString!)
                            
                            /* 8 - If an image exists at the url, set the image and title */
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.photoImageView.image = UIImage(data: imageData)
                                    self.photoTitle.text = photoTitle
                                })
                            } else {
                                println("Image does not exist at \(imageURL)")
                            }
                        } else {
                            println("Found zero photos!")
                        }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}