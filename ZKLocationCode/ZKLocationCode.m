//
//  ZKLocationCode.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2017/1/20.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "ZKLocationCode.h"
#import <objc/runtime.h>
#import <objc/message.h>

// MARK: - UIControl - extionsion
@interface UIControl (extension)

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, copy) NSString *actionName;

@end

// MARK: - ZKLocationLabel
@interface ZKLocationLabel : UILabel
@end

@implementation ZKLocationLabel

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch =touches.anyObject;
    CGPoint point = [touch locationInView:touch.view.superview];
    touch.view.center = point;
}

@end

// MARK: - ZKLocationCode
@interface ZKLocationCode ()

@property (nonatomic, assign) BOOL isvc;
@property (nonatomic, assign) BOOL isBtn;
@property (nonatomic, assign) BOOL isui;
@property (nonatomic, assign) BOOL iscel;

@end

@implementation ZKLocationCode

static id instance;

+ (void)load {
    instance = [[self alloc] init];
}

+ (instancetype)sharedLocationCode {
    return instance;
}

- (void)initTitleLabel {
    self.titleLabel = [ZKLocationLabel new];
    self.titleLabel.textColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.titleLabel];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", [self getCurrentViewControllerWith:[UIApplication sharedApplication].keyWindow.rootViewController.view].class];
    self.titleLabel.frame = CGRectMake(100, 100, 300, 40);
    self.titleLabel.backgroundColor = [UIColor grayColor];
    self.titleLabel.textColor = [UIColor orangeColor];
//    self.titleLabel.alpha = 0.4;
    self.titleLabel.userInteractionEnabled = true;
}

+ (ZKLocationCode *)locationCodeIsVc:(BOOL)vc isBtn:(BOOL)btn isShowUI:(BOOL)ui isCell:(BOOL)cell {
    ZKLocationCode *code = [ZKLocationCode sharedLocationCode];
    code.isvc = vc;
    code.isBtn = btn;
    code.isui = ui;
    code.iscel = cell;
    if (ui) {
        [code initTitleLabel];
    }
    [[UIApplication sharedApplication].keyWindow addObserver:code forKeyPath:@"rootViewController" options:NSKeyValueObservingOptionNew context:nil];
    return code;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.isvc) {
        UIViewController *v = change[@"new"];
        NSLog(@"控制器 %@", v.class);
        if (self.isui) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@", v.class];
            [[UIApplication sharedApplication].keyWindow addSubview:self.titleLabel];
        }
    }
}

- (void)buttonTouchClick:(UIButton *)sender {
    if (self.isBtn) {
        id obj;
        for (id item in sender.allTargets) {
            if (![item isKindOfClass:[ZKLocationCode class]]) {
                obj = item;
            }
        }
        NSLog(@"对象 %@ 方法 %@", [obj class], sender.actionName);
        if (self.isui) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.titleLabel];
            self.titleLabel.text = [NSString stringWithFormat:@"%@", [self getCurrentViewControllerWith:sender].class];
        }
    }
}

- (void)pushVC:(UIViewController *)v {
    if (self.isvc) {
        NSLog(@"控制器 %@", v.class);
        if (self.isui) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@", v.class];
            [[UIApplication sharedApplication].keyWindow addSubview:self.titleLabel];
        }
    }
}

- (void)didSelCell:(UIView *)v action:(NSString *)action {
    if (self.iscel) {
        NSLog(@"对象 %@ 父view %@ 方法 %@", [self getCurrentViewControllerWith:v].class, v.class, action);
    }
}

- (UIViewController *)getCurrentViewControllerWith:(UIView *)v {
    UIResponder *next = [v nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            if ([next isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)next;
                return nav.viewControllers.lastObject;
            }
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

+ (void)swizzleInstanceMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector {
    Method otherMehtod = class_getInstanceMethod(class, otherSelector);
    Method originMehtod = class_getInstanceMethod(class, originSelector);
    method_exchangeImplementations(otherMehtod, originMehtod);
}

+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (NSString *)parameter:(NSDictionary *)dict url:(NSString *)url {
    NSMutableString *str = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@?", url]];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [str appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
    }];
    if (dict.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    return str;
}

@end


// MARK: - UINavigationController extension
@implementation UINavigationController (zk_extension)

+ (void)load {
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UINavigationController") originSelector:@selector(pushViewController:animated:) otherSelector:@selector(zk_pushViewController:animated:)];
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UINavigationController") originSelector:@selector(popViewControllerAnimated:) otherSelector:@selector(zk_popViewControllerAnimated:)];
}

- (void)zk_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self zk_pushViewController:viewController animated:animated];
    [[ZKLocationCode sharedLocationCode] pushVC:viewController];
}

- (UIViewController *)zk_popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [self zk_popViewControllerAnimated:animated];
    [[ZKLocationCode sharedLocationCode] pushVC:[vc.navigationController viewControllers].lastObject];
    return vc;
}

@end

// MARK: - UIViewController extension
@implementation UIViewController (zk_extension)

+ (void)load {
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UIViewController") originSelector:@selector(zk_presentViewController:animated:completion:) otherSelector:@selector(zk_pushViewController:animated:)];
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UIViewController") originSelector:@selector(zk_dismissViewControllerAnimated:completion:) otherSelector:@selector(zk_popViewControllerAnimated:)];
}

- (void)zk_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self zk_presentViewController:viewControllerToPresent animated:flag completion:completion];
    [[ZKLocationCode sharedLocationCode] pushVC:viewControllerToPresent];
}

- (void)zk_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self zk_dismissViewControllerAnimated:flag completion:completion];
    [[ZKLocationCode sharedLocationCode] pushVC:[ZKLocationCode getCurrentVC]];
}

@end

// MARK: - UIControl extension
@implementation UIControl (zk_extension)

const void * VIEWCONTROLLERNAME = "VIEWCONTROLLER";
const void * ACTIONNAME = "ACTIONNAME";

- (void)setViewController:(UIViewController *)viewController {
    objc_setAssociatedObject(self, VIEWCONTROLLERNAME, viewController, OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController *)viewController {
    return objc_getAssociatedObject(self, VIEWCONTROLLERNAME);
}

- (void)setActionName:(NSString *)actionName {
    objc_setAssociatedObject(self, ACTIONNAME, actionName, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)actionName {
    return objc_getAssociatedObject(self, ACTIONNAME);
}

+ (void)load {
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UIControl") originSelector:@selector(addTarget:action:forControlEvents:) otherSelector:@selector(zk_addTarget:action:forControlEvents:)];
}

- (void)zk_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self zk_addTarget:target action:action forControlEvents:controlEvents];
    
    self.viewController = [ZKLocationCode getCurrentVC];
    self.actionName = NSStringFromSelector(action);
    [self zk_addTarget:[ZKLocationCode sharedLocationCode] action:@selector(buttonTouchClick:) forControlEvents:controlEvents];
}

@end

@interface UITableView ()
- (void)_userSelectRowAtPendingSelectionIndexPath:(id)obj;
@end

@implementation UITableView (zk_extension)

+ (void)load {
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UITableView") originSelector:@selector(_userSelectRowAtPendingSelectionIndexPath:) otherSelector:@selector(zk_userSelectRowAtPendingSelectionIndexPath:)];
}

- (void)zk_userSelectRowAtPendingSelectionIndexPath:(id)obj {
    [self zk_userSelectRowAtPendingSelectionIndexPath:obj];
    [[ZKLocationCode sharedLocationCode] didSelCell:self.superview action:@"didSelectRowAtIndexPath"];
}

@end

@implementation UICollectionView (zk_extension)

+ (void)load {
    [ZKLocationCode swizzleInstanceMethod:NSClassFromString(@"UICollectionView") originSelector:@selector(touchesEnded:withEvent:) otherSelector:@selector(zk_touchesEnded:withEvent:)];
}

- (void)zk_touchesEnded:(id)touch withEvent:(id)event {
    [self zk_touchesEnded:touch withEvent:event];
    [[ZKLocationCode sharedLocationCode] didSelCell:self.superview action:@"didSelectRowAtIndexPath"];
}

@end
