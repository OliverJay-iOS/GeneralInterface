//
//  IPPingManager.h
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-6-26.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

#define PINGLOGTAG 1022

@interface serverItem : NSObject {
@public
	NSString * ip;
	NSString * port;
	NSInteger  type;
	NSDate * startTime;
	NSDate * endTime;
    
}

@property (nonatomic, retain) NSString *ip, *port,*name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, assign) int velocityRank;
@property (nonatomic, assign) int bTestSpeedSuccess;

@end

@interface IPPingManager : NSObject<SimplePingDelegate>{
    @public
    void (^TimeoutCallBack)(NSString *) ;
    void (^PingResultCallBack)(float ) ;
}

- (void)runWithHostName:(serverItem *)item;

- (void)onGetFastestIP:(NSArray *)ips;

- (void)onControlReceivePackageTimeinterval;

- (void)setTimeoutBlock:(void (^)(NSString * ))block pingResultBlock:(void (^)(float ))pingBlock;

@property (nonatomic, strong, readwrite) SimplePing *   pinger;
@property (nonatomic, strong, readwrite) NSTimer *      sendTimer;
@property (nonatomic, strong, readwrite) serverItem *   item;
@property (atomic)BOOL bCaculateFinished;


@end
