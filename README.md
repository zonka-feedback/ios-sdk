# Zonka Survey iOS SDK

iOS SDK enables you to collect feedback from your iOS App on iPhone and iPad. 

## Pre Requisites

Zonka Feedback Mobile SDK requires an active Zonka Feedback account. In order to successfully run and test out the survey you would need to have an SDK token for the survey you want to implement. If you are already a user and have access to your SDK token you can directly jump to the Installation section. If not, read on and follow the following steps:

* Create a new account on Zonka Feedback.
* Create a new survey with a choice of questions you would like to implement.
* Once your survey is created go to Distribute menu and click on the In-App tab.
* Enable the toggle to view the SDK token.
* Follow the below-mentioned steps to implement it in your app.

## Minimum Requirements

iOS SDK enables you to collect feedback from your iOS App on iPhone and iPad.

* Recommended using Xcode 13 or above.

* Targeting iOS 12.1 or above.

* Swift 5

## Installation

### Installing using CocoaPods

Define pod in your Podfile and run pod install.

``` ruby
source "https://github.com/CocoaPods/Specs.git"
platform :ios, "12.1"
use_frameworks!

pod "ZonkaFeedback"
```

Then run:

``` bash
pod install
```

## Setup

Create a In-App SDK token for the required survey from Distribute menu and use that to initialize the survey using the SDK

### Initialize ZFSurvey

Create an SDK token for the required survey from Distribute menu and use that to initialize the ZFSurvey object in your AppDelegate Class. Also, specify the region of your Zonka Feedback account. 
For specifying the region use US for the US region and EU for EU region. 


#### Swift

``` 
import ZonkaFeedback

class AppDelegate: UIResponder, UIApplicationDelegate 
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
     {
          ZFSurvey.sharedInstance().initializeSDK(token: "<<SDK_TOKEN>>",zfRegion: "<<REGION>>")
     
          return true
     }
}

```

#### Initialization in SwiftUI projects, with no AppDelegate class

ZonkaFeedback iOS SDK can be used in SwiftUI projects. If your SwiftUI project doesn’t use the AppDelegate class, the initialization can be done in the constructor of the main application class:

``` 
import ZonkaFeedback

@main
struct SwiftUIApp: App 
{
    init() 
    {
          ZFSurvey.sharedInstance().initializeSDK(token: "<<SDK_TOKEN>>",zfRegion: "<<REGION>>")
    }
}

```

#### Objective C


``` 
 #import <ZonkaFeedback-Swift.h>


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [[ZFSurvey sharedInstance] initializeSDKWithToken:@"<<SDK_TOKEN>>" zfRegion:@"<<REGION>>"];
}

```

## Identifying Logged in Visitors

If you have an app where users are able to log in or signup then you can add the following code to automatically add the contacts in Zonka Feedback. You can pass at least one of the following parameters to identify the users.

### Example:-

#### Swift

``` 
   import ZonkaFeedback
    
   let userInfoDict = NSMutableDictionary()
   userInfoDict.setValue("james@examplemail.com", forKey: "contact_email")
   userInfoDict.setValue("James Robinson", forKey: "contact_name")
   userInfoDict.setValue("+919191919191”, forKey: "contact_mobile")
   ZFSurvey.sharedInstance().userInfo(dict: userInfoDict)
   
```

#### Objective c

``` 
  #import <ZonkaFeedback-Swift.h>

  NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]init]; 
  [userInfoDict setValue:@"james@examplemail.com" forKey:@"contact_email"];  
  [userInfoDict setValue:@"James Robinson" forKey:@"contact_name"];
  [userInfoDict setValue:@"+919191919191" forKey:@"contact_mobile"];      
  [[ZFSurvey sharedInstance] userInfoWithDict:userInfoDict];
  
```

## Using ZonkaFeedback SDK

ZonkaFeedback SDK allows you to launch precisely targeted surveys inside your app. In Zonka Feedback web  Panel you can create a survey and use it on anywhere within your app.


Create an instance of ZFSurveyViewController in any ViewController you want to integrate zonka survey.

let surveyViewController = ZFSurveyViewController()

### Parameters

#### 1.sendDeviceDetails(Optional)

You can set the value of sendDeviceDetails to true if you want to submit details of your device along with the Zonka Feedback survey response. This would send the details of the device such as OS, OS version, IP address, and type of device. When you implement SDK it's true by default.


#### 2.sendCustomAttributes(Optional)

You can pass additional data about your users to provide more meaningful data along with the response. Some of the examples can be screen name, order Id, or transaction Id which can be associated with the response.

Attributes can be used to:
Identify respondents (by default survey responses are anonymous)
Trigger surveys
Filter survey results

     
### Example:-

#### Swift

``` 
    import ZonkaFeedback
    
    func openSurvey()
    {
        let surveyViewController = ZFSurveyViewController()
        surveyViewController.sendDeviceDetails = true
        
        let attributesDict = NSMutableDictionary()
        attributesDict.setValue("james@examplemail.com", forKey: "contact_email")
        attributesDict.setValue("James Robinson", forKey: "contact_name")
        attributesDict.setValue("+919191919191”, forKey: "contact_mobile")
        surveyViewController.sendCustomAttributes = attributesDict
        self.view.addSubview(surveyViewController.view)
    }

```


#### Objective c

``` 
   #import <ZonkaFeedback-Swift.h>

  -(void)openSurvey
  {                    
        ZFSurveyViewController *surveyViewController = [ZFSurveyViewController new];
        surveyViewController.sendDeviceDetails = true;
       
        NSMutableDictionary *attributesDict = [[NSMutableDictionary alloc]init];
        [attributesDict setValue:@"james@examplemail.com" forKey:@"contact_email"];  
        [attributesDict setValue:@"James Robinson" forKey:@"contact_name"];
        [attributesDict setValue:@"+919191919191" forKey:@"contact_mobile"]; 
         surveyViewController.sendCustomAttributes = attributesDict;
        [self.view addSubview:surveyViewController.view];
  }
  

```

## Reset Visitor Attributes

If you are using the above code to identify users, then it might be good idea to clear visitor data on logout. Use the below code to clear the data.

### Example:-

#### Swift

``` 
    import ZonkaFeedbackSDK
    
    func logout()
    {
        ZFSurvey.sharedInstance().clear()
    }

```


#### Objective c

``` 
   #import <ZonkaFeedback-Swift.h>

  -(void)logout
  {
     [[ZFSurvey sharedInstance] clear];
  }
  
```



