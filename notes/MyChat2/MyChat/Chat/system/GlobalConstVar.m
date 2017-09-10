#import <UIKit/UIKit.h>
/** 占位图片*/
NSString * const placeholderName = @"placeholder";
NSString * const chat_me_img = @"chat_me";
NSString * const chat_oth_img = @"chat_bg";
/** 一天的毫秒数*/
long const dayMS = 86400000;




long _time_now(){
    time_t rawtime;
    time ( &rawtime );
    
    return rawtime * 1000;
}
NSString *dateStr(long timeInterval, bool isBeyondDay){
    struct tm * timeinfo;
    timeinfo = localtime ( &timeInterval );
    timeinfo->tm_mon ++;
    if(timeinfo->tm_mon == 11)timeinfo->tm_mon = 1;
    if(isBeyondDay){
        return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d:%02d",(*timeinfo).tm_year + 1900,(*timeinfo).tm_mon,(*timeinfo).tm_mday,(*timeinfo).tm_hour,(*timeinfo).tm_min,(*timeinfo).tm_sec];
    }else{
        return [NSString stringWithFormat:@"%d:%d:%d",(*timeinfo).tm_hour,(*timeinfo).tm_min,(*timeinfo).tm_sec];
    }
}


#warning 代码拉伸有问题
UIImage *strechChat_Me_BgImg(){
    UIImage *image = [UIImage imageNamed:chat_me_img];
    CGSize size = image.size;
    image = [image stretchableImageWithLeftCapWidth:size.width * 0.7 topCapHeight:size.height * 0.5];
    return image;
}

UIImage *strechChat_Oth_BgImg(){
    UIImage *image = [UIImage imageNamed:chat_oth_img];
    CGSize size = image.size;
    image = [image stretchableImageWithLeftCapWidth:size.width * 0.5 topCapHeight:size.height * 0.7];
    return image;
}








