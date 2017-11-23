//
//  AuthenticationResult.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class AuthenticationResult: NSObject {
    var Result : AuthenticationResultTypes?
    var OperationResult = Int()
    var AccessToken : String?
    var Profile : CustomerProfile?
    
    override init() {
        super.init()
        
    }
}
