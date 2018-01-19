![CocoaPods](https://img.shields.io/cocoapods/v/FideasLib.svg)

# FIDEAS SDK
# Installing
###  Cocoa Pods
```ruby
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
    pod 'FideasLib'
end
```

# Usage

#### Initialization

```swift
import FideasLib
```
### Register

#### Signature

```swift
    public func Register(IdentityNumber:String,
                         Name:String,
                         Surname:String,
                         Email:String,
                         PhoneNumber:String,
                         DateOfBirth:String,
                         RetailerID:String,
                         DeviceID:String,
                         callbackFunction:@escaping(_ result: RegisterOperationResult) -> Void
        )
```
#### Code Example
```swift
import UIKit
import FideasLib

class RegisterViewController: UIViewController
{
    func Register()->
    {
        let service = FideaConnector()
        service.Register(IdentityNumber: txtIdentityNumber.text!, Name: txtNameSurname.text!, Surname: "", 
        Email: txtEmail.text!, PhoneNumber: txtPhoneNumber.text!, DateOfBirth: txtBirthDate.text!, 
        RetailerID: _retailerID, DeviceID: self.GetDeviceID(),callbackFunction: {
                result in
                //Success
                if(result.OperationStatus == 200)
                {
                }
                else
                {}
          }
       )
    }
}
```

### Login

#### Signature

```swift
public func Login(Identity:String,MobileNumber:String,DeviceID:String,RetailerID:String,callback:@escaping(_ result: AuthenticationResult) -> Void)
```

#### Code Example

```swift
import UIKit
import FideasLib
class LoginViewController: UIViewController
{
    func Login()
    {
        let service = FideaConnector()
        service.Login(Identity: txtIdentityNumber.text!, MobileNumber: txtPhoneNumber.text!, DeviceID: self.GetDeviceID(), RetailerID: _retailerID, callback: {
            result in
            if(result.Result == AuthenticationResultTypes.Success)
            {
              }  
      })
    }
}
```

### RequestKKBReport 

#### Signature

```swift
public func RequestKKBReport(MobileNumber:String,
                                 IdentityNumber:String,
                                 FirstName:String,
                                 LastName:String,
                                 DateOfBirth:String,
                                 Email:String,
                                 RetailerID:String,
                                 DeviceID:String,
                                 callbackFunction:@escaping(_ result: KKBRequestResponse) -> Void) {
    
``` 

#### Code Example 

```swift 

import UIKit
import FideasLib
class LoginViewController: UIViewController
{

    func RequestKKBReport(){
           service.RequestKKBReport(MobileNumber: currentUser.PhoneNumber, IdentityNumber: currentUser.IdentityNumber, 
           FirstName: "", LastName: "", DateOfBirth: currentUser.BirthDate, Email: "", 
           RetailerID: _retailerID, DeviceID: self.GetDeviceID(), callbackFunction: {
                    reportRequest in    
                    if(reportRequest.RequestID > 0)
                    {
                        let pin = PinEntryViewController()
                        pin.RequestID = reportRequest.RequestID
                        self.navigationController?.pushViewController(pin, animated: true)
                    }
                    else
                    {
                        if(reportRequest.Decision?.Decision == "DECLINE")
                        {
                            let decline = DeclineLimitViewController()
                            self.navigationController?.pushViewController(decline, animated: true)
                        }
                    }
                })
      }
 }
 ```

### CheckKKBResponse

#### Signature

```swift
public func CheckKKBResponse(IdentityNumber:String,
                                 DateOfBirth:String,
                                 Pin:String,
                                 RequestID:String,
                                 callbackFunction:@escaping(_ result:KKBResponse) -> Void
        )
``` 

#### Code Example 

```swift 
service.CheckKKBResponse(IdentityNumber: user.IdentityNumber, DateOfBirth: user.BirthDate, Pin: pin, RequestID: String(RequestID), callbackFunction: {
            result in 
            //Pin check is success
            if(result.IsSuccess && result.ProcessResult == "1")
            {
               //Check the report status here. 
               
            }
            else
            {
                // invalid pin entry
            }
        
        })
    }
```

### CheckReportStatus 

#### Signature 

```swift
public func CheckReportStatus(IdentityNumber: String,RequestID: String,callbackFunction:@escaping(_ result : ReportQueryResult) -> Void)
```

#### Code Example 

```swift
service.CheckReportStatus(IdentityNumber: user.IdentityNumber, RequestID: String(self.RequestID), 
callbackFunction: {
                    retval in
                    switch(retval.StatusCode)
                    {
                    case "3","4":
                    // Report is preparing    
                    case "5":
                    // Report is ready call the GetKKBReport Function
                    default:
                    
                    }
                    
                })
```

### GetKKBReport 

#### Signature

```swift
    public func GetKKBReport(IdentityNumber:String,
                             DateOfBirth:String,
                             RequestID:String,
                             callbackFunction:@escaping(_ result: ReportResult) -> Void
        )

```

#### Code Example 

```swift
service.GetKKBReport(IdentityNumber: user.IdentityNumber, DateOfBirth: user.BirthDate, RequestID: String(self.RequestID), callbackFunction: {
                            report in
                            if(report.IsSuccess)
                            {
                                if(report.Decision?.Decision == "DECLINE")
                                {
                                    //Show decline view controller
                                }
                                else
                                {
                                   //Show home view controller 
                                }
                            }
                        })
```

### UpdateProfile 

#### Signature 

```swift
    public func UpdateProfile(IdentityNumber:String,
                              FirstName:String,
                              LastName:String,
                              DateOfBirth:Date,
                              MobileNumber:String,
                              EmailAddress:String,
                              DeviceID:String,
                              RetailerID:String,
                              callbackFunction: @escaping(_ result: UpdateOperationResult) -> Void
        )
```

#### Code Example 

```swift 
service.UpdateProfile(IdentityNumber: txtIdentityNumber.text!,
                              FirstName: self.txtNameSurname.text!.components(separatedBy: " ")[0],
                              LastName: self.txtNameSurname.text!.components(separatedBy: " ").count>1 ? self.txtNameSurname.text!.components(separatedBy: " ")[1] : "",
                              DateOfBirth: df.date(from: txtBirthDate.text!)!,
                              MobileNumber: txtPhoneNumber.text!, EmailAddress: txtEmail.text!, DeviceID: self.GetDeviceID(), RetailerID: _retailerID, callbackFunction: {
                                update in
                                //Operation is success
                                if(update.Result==200)
                                {
                                    
                                }
                                
                                
        })
```
