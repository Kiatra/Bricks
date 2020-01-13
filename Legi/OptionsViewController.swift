//
//  ViewController.swift
//  Legi
//
//  Created by jan on 18/03/16.
//  Copyright © 2016 Jan Parizek. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
