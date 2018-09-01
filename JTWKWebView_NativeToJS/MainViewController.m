//
//  MainViewController.m
//  ArtRoomStudent
//
//  Created by 黄金台 on 2018/8/2.
//  Copyright © 2018年 黄金台. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

#import "AppDelegate.h"
#import "ScanViewController.h"
#import "ChoosePoiViewController.h"

@interface MainViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebViewJavascriptBridge         *webViewBridge;
@property (nonatomic, strong) WKWebView                         *webView;
@property (nonatomic, strong) UIProgressView                    *progressView;
@property (nonatomic, strong) AMapLocationManager               *locationManager;

@end

@implementation MainViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[AMapLocationManager alloc]  init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建webView
    [self setupSubViews];
    
    // 注册JS调用OC的方法
    [self registerNativeFunctions];
    
    // 这个是JS中调用OC的方法
//    JSCallOC
    
    // 加载HTML
    NSURL *htmlUrl = [[NSBundle mainBundle] URLForResource:@"home" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
}


- (void)setupSubViews
{
    // 添加WKWebView
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 13.0f;
    preferences.javaScriptEnabled = YES;
    configuration.preferences = preferences;
    configuration.processPool = [[WKProcessPool alloc] init];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    // 初始化WKWebViewJavascriptBridge， 并设置代理
    self.webViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.webViewBridge setWebViewDelegate:self];
    
    if (@available(ios 11.0,*))
    {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}


#pragma mark =========================== WKNavigationDelegate ===========================
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s -- %@", __func__, navigation);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s -- %@", __func__, navigation);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s -- %@ --- %@", __func__, navigation, error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s -- %@", __func__, navigation);
}

#pragma mark =========================== WKUIDelegate ===========================

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message = %@, frame = %@", message, frame);
    
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    NSLog(@"prompt = %@, defaultText = %@, frame = %@", prompt, defaultText, frame);
    
    completionHandler(@"");
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"message = %@, frame = %@", message, frame);
    
    completionHandler(true);
}

#pragma mark =========================== help ===========================


- (void)alertUserWith:(NSString *)title message:(NSString *)message
{
    if (!message) {
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark =========================== OC调用JS ===========================

// 注册JS调用原生方法
- (void)registerNativeFunctions
{
    // 1  扫一扫
    [self registScanFunction];
    // 2  分享
    [self registShareFunction];
    // 3  微信登录
    [self registWXLoginFunction];
    // 4  QQ登录
    [self registQQLoginFunction];
    // 5  微博登录
    [self registWBLoginFunction];
    // 6  高德选点
    [self registChoosePoiFunction];
    // 7  微信支付
    [self registWXPayFunction];
    // 8  支付宝支付
    [self registAliPayFunction];
    // 9  用户定位
    [self registGetLocationFunction];
    // 10 复制文本
    [self registCopyTextFunction];
    // 11 导航
    [self registNavigationPointFunction];
    // 12 软件更新
    [self registUpdateAppFunction];
}


#pragma mark =========================== 扫一扫 ===========================

- (void)registScanFunction
{
    [self.webViewBridge registerHandler:@"scan" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"扫一扫   ---   %@", data);
        
        [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
            if (granted) {
                ScanViewController *scanVC = [[ScanViewController alloc] init];
                scanVC.scanResultCallback = [responseCallback copy];
                scanVC.libraryType = [Global sharedManager].libraryType;
                scanVC.scanCodeType = [Global sharedManager].scanCodeType;
                scanVC.style = [StyleDIY qqStyle];
                [self.navigationController pushViewController:scanVC animated:YES];
            }
            else if(!firstTime)
            {
                // 提示打开相机权限
                [self alertUserWith:JTCameraAlertTitle message:JTCameraAlertMessage];
            }
        }];
    }];
}

#pragma mark =========================== 分享 ===========================

- (void)registShareFunction
{
    [self.webViewBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"分享   ---   %@", data);
        
        NSDictionary *dic = (NSDictionary *)data;
        
        // 分享平台 -- 分享子场景
        NSString *platformName = dic[@"platformName"];
        SSDKPlatformType platFormType = SSDKPlatformTypeWechat;
        SSDKPlatformType subType = SSDKPlatformTypeWechat;
        if ([platformName isEqualToString:@"Wechat"]) {
            platFormType = SSDKPlatformTypeWechat;
            subType = SSDKPlatformTypeWechat;
        }
        else if ([platformName isEqualToString:@"WechatMoments"]) {
            platFormType = SSDKPlatformTypeWechat;
            subType = SSDKPlatformSubTypeWechatTimeline;
        }
        else if ([platformName isEqualToString:@"WechatFav"]) {
            platFormType = SSDKPlatformTypeWechat;
            subType = SSDKPlatformSubTypeWechatFav;
        }
        else if ([platformName isEqualToString:@"SinaWeibo"]) {
            platFormType = SSDKPlatformTypeSinaWeibo;
        }
        else if ([platformName isEqualToString:@"QQ"]) {
            platFormType = SSDKPlatformTypeQQ;
            subType = SSDKPlatformSubTypeQQFriend;
        }
        else if ([platformName isEqualToString:@"QZone"]) {
            platFormType = SSDKPlatformTypeQQ;
            subType = SSDKPlatformSubTypeQZone;
        }
        
        // 分享内容类型
        int shareType = [dic[@"shareType"] intValue];
        SSDKContentType contentType = SSDKContentTypeWebPage;
        switch (shareType) {
            case 1:
                contentType = SSDKContentTypeText;
                break;
            case 2:
                contentType = SSDKContentTypeImage;
                break;
                break;
            case 3:
                contentType = SSDKContentTypeWebPage;
                break;
            case 4:
                contentType = SSDKContentTypeAudio;
                break;
            case 5:
                contentType = SSDKContentTypeVideo;
                break;
            case 6:
                contentType = SSDKContentTypeApp;
                break;
            case 7:
                contentType = SSDKContentTypeFile;
                break;
            case 8:
                contentType = SSDKContentTypeMiniProgram;
                break;
            default:
                contentType = SSDKContentTypeAuto;
                break;
        }
        
        // 获取分享的参数
        NSString *title = dic[@"title"];
        NSString *content = dic[@"text"];
        NSURL *url = [NSURL URLWithString:dic[@"url"]];
        NSArray *arr = nil;
    
        // 生成分享参数
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        if (SSDKPlatformTypeWechat == platFormType) {  // 微信分享
            [shareParams SSDKSetupWeChatParamsByText:content
                                               title:title
                                                 url:url
                                          thumbImage:nil
                                               image:nil
                                        musicFileURL:nil
                                             extInfo:nil
                                            fileData:nil
                                        emoticonData:nil
                                                type:contentType
                                  forPlatformSubType:subType];
        }
        else if (SSDKPlatformTypeSinaWeibo == platFormType) { // 新浪微博
            platFormType = SSDKPlatformTypeSinaWeibo;
            [shareParams SSDKSetupSinaWeiboShareParamsByText:content
                                                       title:title
                                                      images:arr
                                                       video:nil
                                                         url:url
                                                    latitude:0
                                                   longitude:0
                                                    objectID:nil
                                              isShareToStory:YES
                                                        type:contentType];
            if ([WeiboSDK isWeiboAppInstalled]) {
                //优先使用平台客户端分享
                [shareParams SSDKEnableUseClientShare];
            }
        }
        else if (SSDKPlatformTypeQQ == platFormType) {
            [shareParams SSDKSetupQQParamsByText:content
                                           title:title
                                             url:url
                                   audioFlashURL:nil
                                   videoFlashURL:nil
                                      thumbImage:nil
                                          images:arr
                                            type:contentType
                              forPlatformSubType:SSDKPlatformSubTypeQZone];
        }
        
        // 发起分享
        [ShareSDK share:platFormType
             parameters:shareParams
         onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
             
             if (SSDKResponseStateSuccess == state)
             {
                 [SVProgressHUD showSuccessWithStatus:@"分享成功"];
             }
             else if (SSDKResponseStateCancel == state)
             {
                 [SVProgressHUD showSuccessWithStatus:@"分享取消"];
             }
             else {
                 [SVProgressHUD showErrorWithStatus:@"分享失败"];
             }
         }];
    }];
}


#pragma mark =========================== 微信登录 ===========================

// 微信登录
- (void)registWXLoginFunction
{
    [self.webViewBridge registerHandler:@"wxLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"登录 --- %@", data);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict SSDKSetupWeChatByAppId:WXAppID appSecret:WXAppSecret];
        [ShareSDK authorize:SSDKPlatformTypeWechat settings:dict onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            
            if (SSDKResponseStateSuccess == state) {
                
                NSLog(@"授权成功");
                // 获取用户信息
                NSString * unionid = user.uid;
                NSString * nickname = user.nickname;
                NSString * headimgurl = user.icon;
                int sex = (0 == user.gender) ? 1 : 0;//0女生，1男生
                NSString * openid = user.credential.token;
                
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                [mutDict setValue:unionid forKey:@"unionid"];
                [mutDict setValue:nickname forKey:@"nickname"];
                [mutDict setValue:headimgurl forKey:@"headimgurl"];
                [mutDict setValue:@(sex) forKey:@"sex"];
                [mutDict setValue:openid forKey:@"openid"];
                NSString *result = nil;
                if (@available(iOS 11.0, *)) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingSortedKeys error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                } else {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                
                if (responseCallback) {
                    responseCallback(result);
                }
            }
            else {
                NSLog(@"授权失败");
                [SVProgressHUD showErrorWithStatus:@"授权失败"];
            }
        }];
    }];
}

#pragma mark =========================== QQ登录 ===========================

- (void)registQQLoginFunction
{
    [self.webViewBridge registerHandler:@"qqLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"登录 --- %@", data);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict SSDKSetupQQByAppId:QQAppID appKey:QQAppKEY authType:SSDKAuthTypeBoth];
        
        [ShareSDK authorize:SSDKPlatformTypeQQ settings:dict onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            
            if (SSDKResponseStateSuccess == state) {
                
                NSLog(@"授权成功");
                // 获取用户信息
                NSString * unionid = user.uid;
                NSString * nickname = user.nickname;
                NSString * headimgurl = user.icon;
                int sex = (0 == user.gender) ? 1 : 0;//0女生，1男生
                NSString * openid = user.credential.token;
                
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                [mutDict setValue:unionid forKey:@"unionid"];
                [mutDict setValue:nickname forKey:@"nickname"];
                [mutDict setValue:headimgurl forKey:@"headimgurl"];
                [mutDict setValue:@(sex) forKey:@"sex"];
                [mutDict setValue:openid forKey:@"openid"];
                NSString *result = nil;
                if (@available(iOS 11.0, *)) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingSortedKeys error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                } else {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                
                if (responseCallback) {
                    responseCallback(result);
                }
            }
            else {
                NSLog(@"授权失败");
                [SVProgressHUD showErrorWithStatus:@"授权失败"];
            }
        }];
    }];
}

#pragma mark =========================== 微博登录 ===========================

- (void)registWBLoginFunction
{
    [self.webViewBridge registerHandler:@"wbLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"登录 --- %@", data);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict SSDKSetupSinaWeiboByAppKey:SinaAppKEY appSecret:SinaAppSecret redirectUri:SinaHandleUrl authType:SSDKAuthTypeBoth];
    
        [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:dict onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            
            if (SSDKResponseStateSuccess == state) {
                
                NSLog(@"授权成功");
                // 获取用户信息
                NSString * unionid = user.uid;
                NSString * nickname = user.nickname;
                NSString * headimgurl = user.icon;
                int sex = (0 == user.gender) ? 1 : 0;//0女生，1男生
                //NSString * openid = user.credential.token;
                
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                [mutDict setValue:unionid forKey:@"id"];
                [mutDict setValue:nickname forKey:@"name"];
                [mutDict setValue:headimgurl forKey:@"avatar_hd"];
                [mutDict setValue:[@(sex) isEqualToNumber:@1]?@"m":@"f"  forKey:@"gender"];
                //[mutDict setValue:openid forKey:@"openid"];
                NSString *result = nil;
                if (@available(iOS 11.0, *)) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingSortedKeys error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                } else {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:nil];
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                
                if (responseCallback) {
                    responseCallback(result);
                }
            }
            else {
                NSLog(@"授权失败");
                [SVProgressHUD showErrorWithStatus:@"授权失败"];
            }
        }];
    }];
}

#pragma mark =========================== 高德选点 ===========================

- (void)registChoosePoiFunction
{
    [self.webViewBridge registerHandler:@"choosePoi" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"高德选点   ---   %@", data);
        
        ChoosePoiViewController *poiVC = [[ChoosePoiViewController alloc] init];
        poiVC.poiResultCallback = [responseCallback copy];
        [self.navigationController pushViewController:poiVC animated:YES];
    }];
}

#pragma mark =========================== 微信支付 ===========================

- (void)registWXPayFunction
{
    [self.webViewBridge registerHandler:@"wxPay" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"微信支付   ---   %@", data);
        
        NSDictionary *responesObject = ((NSDictionary *)data)[@"Data"];

        // 发起支付
        PayReq *req = [[PayReq alloc] init];
        req.partnerId = responesObject[@"partnerid"];
        req.prepayId = responesObject[@"prepayid"];
        req.nonceStr = responesObject[@"noncestr"];
        req.timeStamp = [responesObject[@"timestamp"] unsignedIntValue];
        req.package = responesObject[@"package"];
        req.sign = responesObject[@"sign"];
        if ([WXApi sendReq:req]) {
            NSLog(@"正在支付");
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.payResultCallback = [responseCallback copy];
        } else {
            NSLog(@"无法调起微信支付");
            if (responseCallback) {
                responseCallback(@(-1));
            }
        }
    }];
}

#pragma mark =========================== 支付宝支付 ===========================

- (void)registAliPayFunction
{
    [self.webViewBridge registerHandler:@"aliPay" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"支付宝支付   ---   %@", data);
        
        NSDictionary *responesObject = ((NSDictionary *)data)[@"Data"];
        
        // 发起支付
        NSString *orderInfo = [responesObject valueForKey:@"order"];
        if (orderInfo && orderInfo.length > 0 && [orderInfo hasPrefix:@"alipay"]) {
            [[AlipaySDK defaultService] payOrder:orderInfo
                                      fromScheme:@"****"
                                        callback:^(NSDictionary *resultDic) {
                                            // 网页支付回调
                                            int code = [resultDic[@"result"] intValue];
                                            if (9000 == code) {
                                                NSLog(@"支付宝网页支付成功");
                                            }
                                            else {
                                                NSLog(@"支付宝网页支付失败");
                                            }
                                        }];
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.payResultCallback = [responseCallback copy];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"支付失败, 请重试"];
            if (responseCallback) {
                responseCallback(@(-1));
            }
        }
    }];
}

#pragma mark =========================== 用户定位 ===========================

- (void)registGetLocationFunction
{
    [self.webViewBridge registerHandler:@"startLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"定位   ---   %@", data);
        
        [LBXPermission authorizeWithType:LBXPermissionType_Location completion:^(BOOL granted, BOOL firstTime) {
            if (granted) {
                
                self.locationManager = [[AMapLocationManager alloc] init];
                self.locationManager.locationTimeout = 10;
                [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                    
                    if (error) {
                        NSLog(@"定位失败  %@", error);
                    }
                    else {
                        double latitude = location.coordinate.latitude;
                        double longitude = location.coordinate.longitude;
                        
                        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
                        [mutDict setValue:@(latitude) forKey:@"lat"];
                        [mutDict setValue:@(longitude) forKey:@"lon"];
                        [mutDict setValue:regeocode.adcode forKey:@"adcode"];
                        [mutDict setValue:regeocode.formattedAddress forKey:@"address"];
                        
                        NSString *result = nil;
                        if (@available(iOS 11.0, *)) {
                            NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingSortedKeys error:nil];
                            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        } else {
                            NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:nil];
                            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        }
                        NSLog(@"定位的位置: %@", result);
                        
                        // 将结果返回给js
                        if (responseCallback) {
                            responseCallback(result);
                        }
                    }
                }];
            }
            else if(!firstTime)
            {
                // 提示打开定位权限
                [self alertUserWith:JTCameraAlertTitle message:JTCameraAlertMessage];
            }
        }];
    }];
}

#pragma mark =========================== 复制文本 ===========================

- (void)registCopyTextFunction
{
    [self.webViewBridge registerHandler:@"putTextIntoClip" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"复制文本   ---   %@", data);
        NSString *content = ((NSDictionary *)data)[@"Data"];
        
        if (content && content.length > 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = content;
            [SVProgressHUD showSuccessWithStatus:@"复制成功"];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"复制失败"];
        }
    }];
}

#pragma mark =========================== 导航 ===========================

- (void)registNavigationPointFunction
{
    // 百度地图与高德地图、苹果地图采用的坐标系不一样
    [self.webViewBridge registerHandler:@"openNavigation" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"导航   ---   %@", data);
        
        NSDictionary *dic = ((NSDictionary *)data[@"Data"]);
        // 终点经纬度
        double endLatitude = [dic[@"lat"] doubleValue];
        double endLongitude = [dic[@"lon"] doubleValue];
        NSString *desname = dic[@"desname"];
        
        int count = 0;
        BOOL amap = false, baidu = NO;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            count ++;
            amap = YES;
        }
        else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            count ++;
            baidu = YES;
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"导航" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        // 如果用户安装了高德地图或者百度地图，让用户选择
        if (count > 0) {
            if (amap) {
                UIAlertAction *amapAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2", JTAppName, @"", endLatitude, endLongitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
                        
                    }];
                }];
                [alertVC addAction:amapAction];
            }
            if (baidu) {
                UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{%@}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02", @"我的位置", endLatitude, endLongitude, desname] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
                        
                    }];
                }];
                [alertVC addAction:baiduAction];
            }
        }
        UIAlertAction *appleAction = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(endLatitude, endLongitude);
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *tolocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
            tolocation.name = @"目的地";
            
            [MKMapItem openMapsWithItems:@[currentLocation,tolocation]launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
        }];
        [alertVC addAction:appleAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }];
}

#pragma mark =========================== 软件更新 ===========================

- (void)registUpdateAppFunction
{
    [self.webViewBridge registerHandler:@"updateApp" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSLog(@"软件更新   ---   %@", data);

        NSDictionary *dic = (NSDictionary *)data;
        NSString *updateInfo = dic[@"updateInfo"];
        NSString *updateUrl = dic[@"iOSUpdateUrl"];
        int must = [dic[@"must"] intValue];

        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"app升级了" message:updateInfo preferredStyle:UIAlertControllerStyleAlert];
        // 下次更新
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"下次更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:true completion:nil];
        }];
        // 退出
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIWindow *window = app.window;
            [UIView animateWithDuration:0.5f animations:^{
                window.alpha = 0;
            } completion:^(BOOL finished) {
                assert(0);
            }];
        }];
        // 更新
        __weak MainViewController *pre = self;
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:updateUrl]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
                    
                }];
            }

            if (1 == must) {
                [pre.navigationController presentViewController:alertVC animated:YES completion:nil];
            }
        }];
        if (1 == must) {
            [alertVC addAction:exitAction];
        } else {
            [alertVC addAction:cancelAction];
        }
        [alertVC addAction:sureAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }];
}

#pragma mark =========================== JS调用OC ===========================

- (void)OCCallJS
{
    [self.webViewBridge callHandler:@"OCCallJS" data:nil responseCallback:^(id responseData) {
        
        NSLog(@"OC调用JS");
    }];
}




- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    UIEdgeInsets inset = self.view.safeAreaInsets;
    if (inset.top != 20) {
        self.webView.frame = CGRectMake(inset.left, inset.top, CGRectGetWidth(self.view.frame) - (inset.left + inset.right), CGRectGetHeight(self.view.frame) - inset.top);
        self.progressView.frame = CGRectMake(inset.left, inset.top, CGRectGetWidth(self.view.frame) - (inset.left + inset.right), 1);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
