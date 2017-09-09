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
#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString * const placeholderName;
UIKIT_EXTERN long const dayMS;





UIKIT_EXTERN NSString *dateStr(long timeInterval, bool isBeyondDay);

UIKIT_EXTERN long _time_now();

#endif

#endif /* GlobalConstVar_h */
