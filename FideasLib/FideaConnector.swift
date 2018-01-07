//
//  FideaConnector.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}

public class FideaConnector: NSObject {
    
    //http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=
    var ServiceUrl = String()
    public override init() {
        ServiceUrl = "http://37.131.253.21/Mobile/DataviewService.asmx?wsdl="
    }
    public init(Url:String)
    {
        ServiceUrl = Url
    }
    public func Authenticate(ClientID:String,ClientSecret:String)->AuthenticationResult{
        let retval = AuthenticationResult()
        //Alamofire.request("", method: "POST", parameters: "", encoding: "", headers: ")
        return retval
    }
    public func Register(IdentityNumber:String,
                         Name:String,
                         Surname:String,
                         Email:String,
                         PhoneNumber:String,
                         DateOfBirth:String,
                         RetailerID:String,
                         DeviceID:String,
                         callbackFunction:@escaping(_ result: RegisterOperationResult) -> Void
        ){
        
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : Name,
            "Surname" : Surname,
            "DateOfBirth" : DateOfBirth,
            "MobileNumber" : PhoneNumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: ""),
            "EmailAddress" : Email,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequenceID" : "1",
            "AccessToken" : "token"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        var xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<FirstName>\(Name)</FirstName>"
            + "<Surname>\(Surname)</Surname>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<MobileNumber>\(PhoneNumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: ""))</MobileNumber>"
            + "<EmailAddress>\(Email)</EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>1</SequenceID>"
            + "<AccessToken>token</AccessToken>"
            + "<Flags><LoginFlag>Y</LoginFlag></Flags>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let opresult = RegisterOperationResult()
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let responseCode = response["ResponseCode"].element?.text
                    let responseMessage = response["ResponseDescription"].element?.text
                    if(responseCode == "200")
                    {
                        opresult.OperationStatus = 200
                        opresult.ResultDescription = ""
                    }
                    else
                    {
                        opresult.ServiceStatus = 200
                        opresult.OperationStatus = Int(responseCode!)!
                        opresult.ResultDescription = responseMessage!
                    }
                }
                else
                {
                    opresult.OperationStatus = responseCode!
                    
                }
                callbackFunction(opresult)
        }
        
    }
    
    public func Login(Identity:String,MobileNumber:String,DeviceID:String,RetailerID:String,callback:@escaping(_ result: AuthenticationResult) -> Void){
        
        let authResult = AuthenticationResult()
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": Identity,
            "FirstName": "-",
            "Surname": "-",
            "DateOfBirth": "01/01/1981",
            "MobileNumber" : MobileNumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: ""),
            "EmailAddress": "info@info.com",
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequenceID" : "2",
            "AccessToken" : "aaaaaaacb"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        
        var xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(Identity)</IdentityNumber>"
            + "<FirstName></FirstName>"
            + "<Surname></Surname>"
            + "<DateOfBirth></DateOfBirth>"
            + "<MobileNumber>\(MobileNumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: ""))</MobileNumber>"
            + "<EmailAddress></EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>2</SequenceID>"
            + "<AccessToken>token</AccessToken>"
            + "<Flags><LoginFlag>Y</LoginFlag></Flags>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        authResult.Result = AuthenticationResultTypes.Error
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseStatusCode = r.response?.statusCode
                if(responseStatusCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let responseCode = response["ResponseCode"].element?.text
                    let flags = response["Flags"]
                    let responseMessage = response["ResponseDescription"].element?.text
                    let loginStatus  = flags["LoginFlag"].element != nil ? flags["LoginFlag"].element!.text == "Y" : false
                    if(responseCode == "200" || loginStatus){
                        //let decision = response["DecisionEngine"]
                        
                        let customer = CustomerProfile()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        customer.MobileNumber = response["MobileNumber"].element!.text
                        customer.IdentityNumber = response["IdentityNumber"].element!.text
                        
                        //customer.MembershipDate = dateFormatter.date(from: response["MembershipDate"].element!.text)!
                        customer.DateOfBirth = dateFormatter.date(from: response["DateOfBirth"].element!.text)!
                        
                        
                        authResult.Result = AuthenticationResultTypes.Success
                        authResult.Profile = customer
                    }
                    else if (responseCode == "401")
                    {
                        authResult.Result = AuthenticationResultTypes.Failed
                        authResult.Profile = nil
                        authResult.ResponseMessage = responseMessage!
                    }
                }
                else
                {
                    authResult.OperationResult = responseStatusCode!
                    
                    
                }
                callback(authResult)
        }
        
    }
    
    
    public func RequestKKBReport(MobileNumber:String,
                                 IdentityNumber:String,
                                 FirstName:String,
                                 LastName:String,
                                 DateOfBirth:String,
                                 Email:String,
                                 RetailerID:String,
                                 DeviceID:String,
                                 callbackFunction:@escaping(_ result: KKBRequestResponse) -> Void) {
        
        //Check the request
        //If the deviceId same but the cellPhone or identityNumber is different we should block the request
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : FirstName,
            "Surname" : LastName,
            "DateOfBirth" : DateOfBirth,
            "MobileNumber" : MobileNumber,
            "EmailAddress" : Email,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequenceID" : "4",
            "AccessToken" : "token",
            "Flags":  ["LoginFlag" : "Y" ]
        ]
        
        let xmlEngine = XmlCreatorEngine()
        var xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
    
        xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<FirstName>\(FirstName)</FirstName>"
            + "<Surname>\(LastName)</Surname>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<MobileNumber>\(MobileNumber)</MobileNumber>"
            + "<EmailAddress>\(Email)</EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>4</SequenceID>"
            + "<AccessToken>token</AccessToken>"
            + "<Flags><LoginFlag>Y</LoginFlag></Flags>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
        let retval = KKBRequestResponse()
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkb = response["KKB"]
                    let decision = response["DecisionEngine"]
                    
                    if(decision.children.count>0)
                    {
                        retval.Decision = DecisionEngine()
                        retval.Decision?.Decision =   decision["Decision"].element != nil ? decision["Decision"].element!.text : ""
                        retval.Decision?.ReasonCode = decision ["ReasonCode"].element != nil ? decision["ReasonCode"].element!.text : ""
                        retval.Decision?.ReasonDescription = decision["ReasonDescription"].element != nil ?  decision["ReasonDescription"].element!.text : ""
                        
                    }
                    
                    retval.RequestID = kkb["KKBtalepId"].element != nil ? Int((kkb["KKBtalepId"].element!.text))! : -1
                    if(retval.Decision?.Decision! != "DECLINE"){
                        retval.ErrorCode = kkb["talepBaslatResponse"]["return"]["hataKodu"].element != nil ? Int((kkb["talepBaslatResponse"]["return"]["hataKodu"].element!.text))! : -1
                        retval.ErrorMessage = kkb["talepBaslatResponse"]["return"]["hataMesaji"].element != nil ?  (kkb["talepBaslatResponse"]["return"]["hataMesaji"].element!.text) : ""
                        retval.RequestResult = kkb["talepBaslatResponse"]["return"]["islemSonucu"].element != nil ? Int((kkb["talepBaslatResponse"]["return"]["islemSonucu"].element!.text))! : -1
                    }
                }
                else
                {
                    retval.ErrorCode = responseCode!
                    retval.ErrorMessage = "KKB işlemi sırasında bir hata oluştu. Lütfen daha sonra tekrardan deneyiniz."
                    
                }
                callbackFunction(retval)
        }
        
        
    }
    
    public func CheckKKBResponse(IdentityNumber:String,
                                 DateOfBirth:String,
                                 Pin:String,
                                 RequestID:String,
                                 callbackFunction:@escaping(_ result:KKBResponse) -> Void
        ){
        let response = KKBResponse()
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "DateOfBirth" : DateOfBirth,
            "Pin" : Pin,
            "KKBtalepId" : RequestID,
            "SequenceID" : "5"
            
        ]
        
        let xmlEngine = XmlCreatorEngine()
        var xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<Pin>\(Pin)</Pin>"
            + "<KKBtalepId>\(RequestID)</KKBtalepId>"
            + "<SequenceID>5</SequenceID>"
            + "<AccessToken>token</AccessToken>"
            + "<Flags><LoginFlag>Y</LoginFlag></Flags>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        URLCache.shared.removeAllCachedResponses()
        
        response.IsSuccess = false
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let resp = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkb = resp["KKB"]
                    if(kkb["talepOnayPin"].children.count>0)
                    {
                        if(kkb["talepOnayPin"]["return"].children.count>0)
                        {
                            response.ErrorCode = kkb["talepOnayPin"]["return"]["hataKodu"].element!.text
                            response.ErrorMessage = kkb["talepOnayPin"]["return"]["hataMesaji"].element!.text
                            response.ProcessResult = kkb["talepOnayPin"]["return"]["islemSonucu"].element!.text
                        }
                    }
                    response.IsSuccess = true
                }
                else
                {
                    response.IsSuccess = false
                }
                callbackFunction(response)
        }
        
        
    }
    
    public func CheckReportStatus(IdentityNumber: String,RequestID: String,callbackFunction:@escaping(_ result : ReportQueryResult) -> Void)
    {
        let result = ReportQueryResult()
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "KKBTalepId" : RequestID,
            "SequenceID" : "14"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        //let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        let xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<KKBtalepId>\(RequestID)</KKBtalepId>"
            + "<SequenceID>14</SequenceID>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        let url = NSURL(string:ServiceUrl + "&rand="+String(arc4random_uniform(1000000)))
        
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.addValue("private", forHTTPHeaderField: "Cache-Control")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        URLCache.shared.removeAllCachedResponses()
        
        Alamofire.request(req as URLRequestConvertible).response{ r in
            let xml = SWXMLHash.parse(r.data!)
            let responseCode = r.response?.statusCode
            if(responseCode == 200)
            {
                let responseXml = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                let kkbXml = responseXml["KKB"]["talepDurumSorgulaResponse"]["return"]
                
                result.ErrorCode = kkbXml["hataKodu"].element!.text
                result.ErrorMessage = kkbXml["hataMesaji"].element!.text
                result.StatusCode = kkbXml["talepListesi"]["durumKodu"].element!.text
                result.StatusDescription = kkbXml["talepListesi"]["durumKoduAciklamasi"].element!.text
                result.RequestID = kkbXml["talepListesi"]["talepId"].element!.text
                
                
            }
            else
            {
                result.ErrorCode="-1"
            }
            callbackFunction(result)
        }
        
    }
    public func GetKKBReport(IdentityNumber:String,
                             DateOfBirth:String,
                             RequestID:String,
                             callbackFunction:@escaping(_ result: ReportResult) -> Void
        ){
        
        let result = ReportResult()
        
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "DateOfBirth" : DateOfBirth,
            "KKBTalepId" : RequestID,
            "SequenceID" : "6"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        var xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        xmlContent = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<KKBtalepId>\(RequestID)</KKBtalepId>"
            + "<SequenceID>6</SequenceID>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let responseXml = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkbXml = responseXml["KKB"]
                    let decision = responseXml["DecisionEngine"]
                    if(kkbXml.children.count>0){
                        result.CreditScore = kkbXml["bkKrediNotu"].element != nil ? kkbXml["bkKrediNotu"].element!.text : ""
                    }
                    if(decision.children.count>0)
                    {
                        result.Decision = DecisionEngine()
                        result.Decision?.Decision = decision["Decision"].element != nil ?  decision["Decision"].element!.text : ""
                        result.Decision?.ReasonCode = decision["ReasonCode"].element != nil ?  decision["ReasonCode"].element!.text : ""
                        result.Decision?.ReasonCode = decision["ReasonDescription"].element != nil ?  decision["ReasonDescription"].element!.text : ""
                        
                    }
                    result.LimitPerCustomer = responseXml["LimitPerConsumer"].element!.text
                    result.UnusedLimit = responseXml["UnusedLimit"].element!.text
                    result.IsSuccess = true
                    
                    
                }
                else
                {
                    result.IsSuccess = false
                }
                callbackFunction(result)
        }
        
        
    }
    
    public func UpdateProfile(IdentityNumber:String,
                              FirstName:String,
                              LastName:String,
                              DateOfBirth:Date,
                              MobileNumber:String,
                              EmailAddress:String,
                              DeviceID:String,
                              RetailerID:String,
                              callbackFunction: @escaping(_ result: UpdateOperationResult) -> Void
        ) {
        
        
        let df = DateFormatter()
        df.dateFormat="dd/MM/yyyy"
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : FirstName,
            "Surname" : LastName,
            "DateOfBirth" : df.string(from: DateOfBirth),
            "MobileNumber" : MobileNumber,
            "EmailAddress" : EmailAddress,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequenceID" : "3",
            "AccessToken" : "token"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let result = UpdateOperationResult()
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let respCode = response["ResponseCode"].element?.text
                    let responseMessage = response["ResponseDescription"].element?.text
                    let updateFlag = response["Flags"]["UpdateSuccessfulFlag"].element != nil ? response["Flags"]["UpdateSuccessfulFlag"].element!.text == "Y" : false
                    if(respCode == "200" || updateFlag)
                    {
                        result.Result = 200
                        result.Message = "Profil Başarılı bir şekilde güncellenmiştir."
                    }
                    else
                    {
                        result.Result = Int(respCode!)!
                        result.Message = responseMessage!
                    }
                }
                else
                {
                    result.Result = responseCode!
                    result.Message = "İşlem sırasında bir hata ile karşılaşıldı."
                }
                callbackFunction(result)
        }
        
        
    }
    
}

