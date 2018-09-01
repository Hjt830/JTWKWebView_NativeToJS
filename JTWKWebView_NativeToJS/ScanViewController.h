//
//  ScanViewController.h
//  ArtRoomStudent
//
//  Created by 黄金台 on 2018/8/4.
//  Copyright © 2018年 黄金台. All rights reserved.
//

#import "LBXAlertAction.h"
#import <LBXScanViewController.h>
#import "WebViewJavascriptBridge.h"
 
@interface ScanViewController : LBXScanViewController <LBXScanViewControllerDelegate>

@property (nonatomic, copy) WVJBResponseCallback         scanResultCallback;

@end
