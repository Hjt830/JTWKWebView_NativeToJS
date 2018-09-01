//
//  AppDelegate.m
//  JTWKWebView_NativeToJS
//
//  Created by Hjt on 2018/8/27.
//  Copyright © 2018年 Hjt. All rights reserved.
//

#import "AppDelegate.h"
//高德地图
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化第三方SDK
    [self initThirdParty];
    
    return YES;
}

#pragma mark =========================== 初始化第三方SDK ===========================

- (void)initThirdParty
{
    // 注册微信支付
    [WXApi registerApp:WXAppID enableMTA:YES];
    // 注册高德地图
    [AMapServices sharedServices].apiKey = AMAPKEY;
    // 注册ShareSDK
    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeCopy),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ),
                                        ]
                             onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:SinaAppKEY
                                           appSecret:SinaAppSecret
                                         redirectUri:SinaHandleUrl
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:WXAppID
                                       appSecret:WXAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:QQAppID
                                      appKey:QQAppKEY
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([url.scheme isEqualToString:WXAppID]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            
            int resultStatus = [resultDic[@"resultStatus"] intValue];
            if (9000 == resultStatus) {
                [SVProgressHUD showSuccessWithStatus:@"支付成功"];
                if (self.payResultCallback) {
                    self.payResultCallback(@(0));
                }
            } else {
                [SVProgressHUD showErrorWithStatus:@"支付失败"];
                if (self.payResultCallback) {
                    self.payResultCallback(@(-1));
                }
            }
            self.payResultCallback = nil;
        }];
    }
    
    return YES;
}

#pragma mark =========================== WXApiDelegate ===========================

- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {  // 支付类型
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"支付成功");
                [SVProgressHUD showSuccessWithStatus:@"支付成功"];
                if (self.payResultCallback) {
                    self.payResultCallback(@(0));
                }
                break;
            default:
                NSLog(@"微信支付失败 -- %@", resp.errStr);
                [SVProgressHUD showErrorWithStatus:@"支付失败"];
                if (self.payResultCallback) {
                    self.payResultCallback(@(-1));
                }
                break;
        }
        self.payResultCallback = nil;
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) { // 分享
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"分享成功");
                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                break;
            default:
                NSLog(@"微信分享失败 -- %@", resp.errStr);
                [SVProgressHUD showSuccessWithStatus:@"分享失败"];
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}



@end
