//
//  ViewController.swift
//  FideasLibTest
//
//  Created by SERHAT YALCIN on 14.11.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit
import FideasLib
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func RegisterButtonTapped(_ sender: Any) {
        let lib = FideaConnector()
    }
    
}

