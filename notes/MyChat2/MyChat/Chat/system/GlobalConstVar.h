//
//  GlobalConstVar.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#ifndef GlobalConstVar_h
#define GlobalConstVar_h


#ifdef __OBJC__
#define UIKIT_EXTERN_VAR UIKIT_EXTERN
#define UIKIT_EXTERN_FUN UIKIT_EXTERN

#import <UIKit/UIKit.h>
UIKIT_EXTERN_VAR NSString * const placeholderName;
UIKIT_EXTERN_VAR long const dayMS;



UIKIT_EXTERN_FUN NSString *dateStr(long timeInterval, bool isBeyondDay);
UIKIT_EXTERN_FUN long _time_now();
UIKIT_EXTERN_FUN UIImage *strechChat_Me_BgImg();
UIKIT_EXTERN_FUN UIImage *strechChat_Oth_BgImg();
#endif

#endif /* GlobalConstVar_h */
