//
//  CustomerProfile.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 17.11.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

class CustomerProfile: NSObject {
    
    var MembershipDate = Date()
    var DateOfBirth = Date()
    var MobileNumber = String()
    var IdentityNumber = String()
    var Age = Int()
    var AddressLine1 = String()
    var AddressLine2 = String()
    var PostalCode = String()
    
    var ID = Int()
    
    var KKBResult : KKBResponse?
    
    
    override init() {
        
    }
}
