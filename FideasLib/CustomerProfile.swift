//
//  CustomerProfile.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 17.11.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class CustomerProfile: NSObject {
    
    public var MembershipDate = Date()
    public var DateOfBirth = Date()
    public var MobileNumber = String()
    public var IdentityNumber = String()
    public var Age = Int()
    public var AddressLine1 = String()
    public var AddressLine2 = String()
    public var PostalCode = String()
    
    public var ID = Int()
    
    public var Report : ReportResult?
    
    
    override init() {
        
    }
}
