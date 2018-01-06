//
//  XmlCreatorEngine.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 21.12.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import Foundation
public class XmlCreatorEngine
{
    public init() {
        
    }
    
    public func CreateXmlRequest(Prefix:String, params: Dictionary<String,Any?>, Suffix:String) -> String
    {
        var retval = String()
        var prefix : String = ""
        var suffix : String = ""
        if(Prefix.isEmpty)
        {
            prefix = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
                + "<soapenv:Header/>"
                + "<soapenv:Body>"
                + "<dvt:ProcessApplicationXML>"
                + "<dvt:XmlRequest>"
                + "<Request>"
        }
        else
        {
            prefix = Prefix
        }
        retval.append(prefix)
        
        for (key,value) in params
        {
            if let valueArray : Dictionary<String,Any?> = value as? Dictionary<String,Any?>
            {
                var innerValues = String()
                for (innerKey,innerValue) in valueArray
                {
                    innerValues.append(contentsOf: String(format:"<%@>%@</%@>",innerKey,innerValue as! CVarArg,innerKey))
                }
                retval.append(contentsOf: String(format:"<%@>%@</%@>",key,innerValues,key))
            }
            else
            {
                retval.append(contentsOf: String(format: "<%@>%@</%@>", key,value as! CVarArg,key))
            }
        }
        
        
        if(Suffix.isEmpty)
        {
            suffix =  "</Request>"
                + "</dvt:XmlRequest>"
                + "</dvt:ProcessApplicationXML>"
                + "</soapenv:Body>"
                + "</soapenv:Envelope>"
        }
        else
        {
            suffix = Suffix
        }
        retval.append(suffix)
        return retval
    }
}

