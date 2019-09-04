//
//  ViewController.m
//  CountDown_GCD
//
//  Created by Apple on 2019/8/31.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    dispatch_source_t _timer;
    
    UILabel *dayslab;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 界面UI-Lab
    [self setUI];
    
    /////-------------接口返回截止时间-@"2019-09-18 19:00:00"----
    // 倒计时的时间 测试数据
    NSString *deadlineStr = @"2019-09-18 19:00:00";
    // 当前时间的时间戳
    NSString *nowStr = [self getyyyymmdd];
    // 计算时间差值
    NSInteger secondsCountDown = [self getDateDifferenceWithNowDateStr:nowStr deadlineStr:deadlineStr];
    /////-----------------------------------------------------
    // 传入时间差值实现倒计时
    [self countdownAnd:secondsCountDown];
    
}

-(void)setUI{
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(50, 200, 300, 40)];
    lab.text = @"距离抽奖开始还剩";
    lab.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:lab];
    
    dayslab =  [[UILabel alloc]initWithFrame:CGRectMake(50, 250, 60, 30)];
    dayslab.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:dayslab];

    for(int i = 0; i < 3; i++){

       UILabel *timelab =  [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dayslab.frame)+i*55, CGRectGetMinY(dayslab.frame), 40, 30)];
        timelab.textColor = [UIColor whiteColor];
        timelab.textAlignment = NSTextAlignmentCenter;
        timelab.backgroundColor = [UIColor redColor];
        timelab.font = [UIFont boldSystemFontOfSize:20];
        timelab.layer.cornerRadius = 5;
        [timelab.layer setMasksToBounds:YES];
        timelab.tag = 100+i;
        [self.view addSubview:timelab];

        if (i<2) {
            
            UILabel *dianlab =  [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(timelab.frame), CGRectGetMinY(dayslab.frame), 15, 30)];
            dianlab.textColor = [UIColor redColor];
            dianlab.textAlignment = NSTextAlignmentCenter;
            dianlab.font = [UIFont boldSystemFontOfSize:30];
            dianlab.text = @":";
            [self.view addSubview:dianlab];
        }
       
    }
}

-(void)setDataWithLabAndDay:(NSString *)dayStr andHours:(NSString *)huorStr andMinte:(NSString *)minteStr andSecond:(NSString *)decondStr{
    
    dayslab.text = dayStr;
    NSArray *tarr = @[huorStr,minteStr,decondStr];
    for(int i = 0; i < tarr.count; i++){
        UILabel *lab = (UILabel *)[self.view viewWithTag:100+i];
        lab.text = tarr[i];
    }
}

//=============================================================
// 传入时间差值实现倒计时
-(void)countdownAnd:(NSInteger)timeInterval{
    __weak __typeof(self) weakSelf = self;
    if (_timer==nil) {
        __block NSInteger timeout = timeInterval; //倒计时时间
        
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf setDataWithLabAndDay:@"0" andHours:@"00" andMinte:@"00" andSecond:@"00"];
                    });
                    
                    
                }else{
                    NSInteger days = (int)(timeout/(3600*24));
                    NSInteger hours = (int)((timeout-days*24*3600)/3600);
                    NSInteger minute = (int)(timeout-days*24*3600-hours*3600)/60;
                    NSInteger second = timeout - days*24*3600 - hours*3600 - minute*60;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf setDataWithLabAndDay:[NSString stringWithFormat:@"%ld天", days] andHours:[NSString stringWithFormat:@"%02ld",hours] andMinte:[NSString stringWithFormat:@"%02ld",minute] andSecond:[NSString stringWithFormat:@"%02ld",second]];
                        
                    });
                    timeout--;
                }
            });
            dispatch_resume(_timer);
        }
    }
    
    
}


/**
 *  获取当天的年月日的字符串
 *  这里测试用
 *  @return 格式为年-月-日
 */
-(NSString *)getyyyymmdd{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatDay = [[NSDateFormatter alloc] init];
    formatDay.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dayStr = [formatDay stringFromDate:now];
    return dayStr;
    
}
/**
 *  获取时间差值  截止时间-当前时间
 *  nowDateStr : 当前时间
 *  deadlineStr : 截止时间
 *  @return 时间戳差值
 */
- (NSInteger)getDateDifferenceWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr {
    
    NSInteger timeDifference = 0;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [formatter dateFromString:nowDateStr];
    NSDate *deadline = [formatter dateFromString:deadlineStr];
    NSTimeInterval oldTime = [nowDate timeIntervalSince1970];
    NSTimeInterval newTime = [deadline timeIntervalSince1970];
    timeDifference = newTime - oldTime;
    
    return timeDifference;
}


@end
