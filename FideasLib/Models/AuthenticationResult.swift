//
//  AuthenticationResult.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class AuthenticationResult {
    init() {
        
    }
    public var Result : AuthenticationResultTypes?
    public var ResponseMessage  = String()
    public var OperationResult = Int()
    public var AccessToken : String?
    public var Profile : CustomerProfile?
    
    
}
