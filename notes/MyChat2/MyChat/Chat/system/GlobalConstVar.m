#import <UIKit/UIKit.h>
/** 占位图片*/
NSString * const placeholderName = @"placeholder";

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
    if(isBeyondDay){
        return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d:%02d",(*timeinfo).tm_year,(*timeinfo).tm_mon,(*timeinfo).tm_mday,(*timeinfo).tm_hour,(*timeinfo).tm_min,(*timeinfo).tm_sec];
    }else{
        return [NSString stringWithFormat:@"%d:%d:%d",(*timeinfo).tm_hour,(*timeinfo).tm_min,(*timeinfo).tm_sec];
    }
    
    
}










