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
        params.forEach{
            item in
            if let value : Dictionary<String,Any?> = item.value as? Dictionary<String,Any?>
            {
                var innerValues = String()
                value.forEach{
                    itemValue in
                    innerValues.append(contentsOf: String(format:"<%@>%@</%@>",itemValue.key,itemValue.value as! CVarArg,itemValue.key))
                }
                retval.append(contentsOf: String(format:"<%@>%@</%@>",item.key,innerValues,item.key))
            }
            else
            {
                retval.append(contentsOf: String(format: "<%@>%@</%@>", item.key,item.value as! CVarArg,item.key))
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
