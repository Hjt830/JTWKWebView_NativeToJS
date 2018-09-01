//
//  POITableViewCell.h
//  ArtRoomStudent
//
//  Created by 黄金台 on 2018/8/11.
//  Copyright © 2018年 黄金台. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POITableViewCell : UITableViewCell

// 名称
@property (nonatomic, weak) IBOutlet UILabel         *nameLabel;
// 地址
@property (nonatomic, weak) IBOutlet UILabel         *addressLabel;

@end
