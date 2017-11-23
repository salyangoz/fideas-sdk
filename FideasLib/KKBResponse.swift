//
//  KKBResponse.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class KKBResponse: NSObject {

    var Decision = String()
    var ApplicationScore = Int()
    var ReasonCode = String()
    var ReasonDescription = String()
    var AdverseActionCode1 = String()
    var AdverseActionDesc1 = String()
    var CreditLimit = Decimal()
    
    public override init() {
    
    }
}
