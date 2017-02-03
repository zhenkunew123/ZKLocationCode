//
//  ZKLocationCode.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2017/1/20.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZKLocationCode : NSObject

/// 界面上显示的titleLabel 可以自己改颜色、背景色
@property (nonatomic, strong) UILabel *titleLabel;

///  类方法初始化
///  vc 是否打印当前控制器名称
///  btn 是否打印调用按钮的方法
///  ui 是否显示ui界面
///
+ (ZKLocationCode *)locationCodeIsVc:(BOOL)vc isBtn:(BOOL)btn isShowUI:(BOOL)ui isCell:(BOOL)cell;

@end

@interface UITableView ()
- (void)_userSelectRowAtPendingSelectionIndexPath:(id)obj;
@end
