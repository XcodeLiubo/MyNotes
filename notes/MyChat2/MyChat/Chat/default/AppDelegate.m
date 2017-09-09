//
//  AppDelegate.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/8.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "AppDelegate.h"
#import "LBChatVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [UIWindow createView:^(UIWindow *view) {
        view.opaque = NO;
        view.init_frame(SCREEN_bounds).init_bgColor([UIColor whiteColor]).init_identify(@"keywindow");
        
        LBChatVC *chatVC = [[LBChatVC alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
        
        view.rootViewController = nav;
        [view makeKeyAndVisible];
    }];
    
    
    
    
    return YES;
}
@end
