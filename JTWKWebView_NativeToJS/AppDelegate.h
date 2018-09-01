//
//  AppDelegate.h
//  JTWKWebView_NativeToJS
//
//  Created by Hjt on 2018/8/27.
//  Copyright © 2018年 Hjt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) WVJBResponseCallback         payResultCallback;


@end

