//
//  ViewController.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/21/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let store = DataStore.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.api.get(request: .search(searchTerm: ValidSearch("Star+Wars")!), handler: { data in
            print(data?[1] ?? "non")
        })
        

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

