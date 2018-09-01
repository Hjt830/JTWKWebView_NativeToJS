//
//  config.h
//  HappFarm
//
//  Created by 黄金台 on 2018/2/19.
//
//

#ifndef config_h
#define config_h

#if __OBJC__

/***
 * 颜色
 **/
#define RGBACOLOR(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HexColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 主题色
#define AppTintColor RGBACOLOR(255.0, 255.0, 255.0, 255.0)

/***
 * iOS版本
 **/
#define JT_isIOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

#define JT_isIPhone4 ( kHeight ==  480 ? YES : NO )

/***
 * 判断是否是iPhone X
 **/
#define ISIPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)



/***
 * 宽高
 **/
#define KWidth ([UIScreen mainScreen].bounds.size.width)
#define KHeight ([UIScreen mainScreen].bounds.size.height)

/***
 * 日志
 **/
#ifdef DEBUG
#define JTLOG(...) NSLog(__VA_ARGS__)
#else
#define JTLOG(...) ((void)0)
#endif

/**
 * 系统字体大小
 */
#define JTFont(f) [UIFont systemFontOfSize:f]

/**
 *  是否是空字符串
 */
#define JTIsEmptyString(str)    ((!str \
                                || ([str isEqual:[NSNull null]]) \
                                || (![str isKindOfClass:[NSString class]]) \
                                || ([str isKindOfClass:[NSString class]] && 0 != str.length) \
                                || ([str isKindOfClass:[NSString class]] && [str isEqualToString:@""])) \
                                ? YES : NO)

/**
 *  是否是空数组
 */
#define JTIsEmptyArray(arr)     ((!arr \
                                || ([arr isEqual:[NSNull null]]) \
                                || (![arr isKindOfClass:[NSArray class]]) \
                                || ([arr isKindOfClass:[NSArray class]] && 0 != arr.count)) \
                                ? YES : NO)
/**
 *  是否是空字典
 */
#define JTIsEmptyDictionary(dic)    ((!dic \
                                    || ([dic isEqual:[NSNull null]]) \
                                    || (![dic isKindOfClass:[NSDictionary class]]) \
                                    || ([dic isKindOfClass:[NSDictionary class]] && 0 != dic.count)) \
                                    ? YES : NO)



/**
 * 第三方库的key
 */
// bugly的APPID
#define BuglyAppID @""

// 高德地图Apikey
#define AMAPKEY @""

// 微信AppID
#define WXAppID @""
#define WXAppSecret @""

// 新浪微博AppID
#define SinaAppKEY @""
#define SinaAppSecret @""
#define SinaHandleUrl @""

// 腾讯QQ
#define QQAppID @""
#define QQAppKEY @""

// ShareSDK
#define ShareAppKEY @""
#define ShareAppSecret @""

// 获取应用名称
#define JTAppName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]


/**
 * 一些提示用语
 */
#define JTCameraAlertTitle @"请打开相机权限"
#define JTCameraAlertMessage [NSString stringWithFormat:@"请你到 '设置' - '隐私' - '相机' - '%@' 打开相机服务", JTAppName]

#define JTLocationAlertTitle @"请打开定位权限"
#define JTLocationAlertMessage [NSString stringWithFormat:@"请你到 '设置' - '隐私' - '定位服务' - '%@' 选择打开定位服务", JTAppName]


/**
 * 对self指针的弱引用
 */
#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self

#endif  /* __OBJC__ */

#endif /* config_h */
