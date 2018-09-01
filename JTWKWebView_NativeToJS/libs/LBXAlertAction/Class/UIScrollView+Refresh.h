//
//  UIScrollView+Refresh.h
//  JTBlogDemo_ForMVVM
//
//  Created by Hjt on 16/11/18.
//  Copyright © 2016年 ShenZhenHermallUnion.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface UIScrollView (Refresh)

/**
 添加刷新header

 @param refreshHeader 下拉刷新回调
 */
- (void)addNormalRefreshHeader:(void(^)(void))refreshHeader;



/**
 添加刷新footer

 @param refreshFooter 上拉加载回调
 */
- (void)addNormalRefreshFooter:(void(^)(void))refreshFooter;



/**
 添加Gift刷新header

 @param refreshHeader 下拉刷新回调
 @param images Gift图片集
 @param duration Gift动画时间
 @param state 刷新状态
 */
- (void)addGiftRefreshHeader:(void(^)(void))refreshHeader
                  withImages:(NSArray *)images
                    duration:(NSTimeInterval)duration
                    forState:(MJRefreshState)state;

- (void)endRefreshHeader;
- (void)endRefreshFooter;
- (void)endRefreshFooterWithNoMoreData;

@end
