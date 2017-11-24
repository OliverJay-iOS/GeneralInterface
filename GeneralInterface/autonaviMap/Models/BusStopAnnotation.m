//
//  BusStopAnnotation.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-26.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#if defined(TARGET_OS_IPHONE) && defined(ENABLE_AMAP)

#import "BusStopAnnotation.h"

@interface BusStopAnnotation ()

@property (nonatomic, readwrite, strong) AMapBusStop *busStop;

@end

@implementation BusStopAnnotation
@synthesize busStop    = _busStop;

#pragma mark - MAAnnotation Protocol

- (NSString *)title
{
    return self.busStop.name;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"ID = %@", self.busStop.uid];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.busStop.location.latitude, self.busStop.location.longitude);
}

#pragma mark - Life Cycle

- (id)initWithBusStop:(AMapBusStop *)busStop
{
    if (self = [super init])
    {
        self.busStop = busStop;
    }
    
    return self;
}

@end


#endif
