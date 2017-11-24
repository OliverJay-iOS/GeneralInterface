//
//  IPPingManager.m
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-6-26.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "IPPingManager.h"
#include "SimplePing.h"
#include <sys/socket.h>
#include <netdb.h>
//#import "DebugPublicMethod.h"
#include <string>
#import "IPPingHelper.h"

using namespace std;

@implementation serverItem

@synthesize name,ip, port, type;
@synthesize startTime;
@synthesize endTime;
@synthesize bTestSpeedSuccess;

- (id)init{
    self = [super init];
    if(self){
        name = @"";
        ip = @"";
        port = @"";
        startTime = nil;
        endTime = nil;
    }
    
    return self;
}

- (id)initWithServerItem:(serverItem *)item{
    self = [super init];
    if(self){
        name = item.name;
        ip = item.ip;
        port = item.port;
        startTime = item.startTime;
        endTime = item.endTime;
        type = item.type;
        bTestSpeedSuccess = item.bTestSpeedSuccess;
    }
    
    return self;
}

- (void)dealloc {
    
}

@end

#pragma mark * Utilities

static NSString * DisplayAddressForAddress(NSData * address)
{
    return [IPPingHelper getAddressForAddress:address];
}

@implementation IPPingManager
    
@synthesize pinger    = _pinger;
@synthesize sendTimer = _sendTimer;
@synthesize bCaculateFinished;

- (void)dealloc
{
    [self->_pinger stop];
    [self->_sendTimer invalidate];
}

- (NSString *)shortErrorFromError:(NSError *)error
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    result = nil;
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                }
            }
        }
    }
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    return result;
}

- (void)runWithHostName:(serverItem *)item
{
    self.pinger = [SimplePing simplePingWithHostName:item.ip];
    _item = [[serverItem alloc]initWithServerItem:item];
    
    self.pinger.delegate = self;
    [self.pinger start];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    while (self.pinger != nil);
}

//static int sendPingCount = 0;
- (void)sendPing
{
    [self.pinger sendPingWithData:nil];
}

- (void)onControlReceivePackageTimeinterval{
    if(_item.endTime == nil && self.pinger){
        [self.pinger stop];
        self.pinger = nil;
        _item.bTestSpeedSuccess = NO;
        
        if(TimeoutCallBack){
            TimeoutCallBack(@"发送ping包5s超时");
        }
    }
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
// A SimplePing delegate callback method.  We respond to the startup by sending a
// ping immediately and starting a timer to continue sending them every second.
{
#pragma unused(pinger)
    NSLog(@"pinging  %@", DisplayAddressForAddress(address));
    char * cAddress = const_cast<char *>([DisplayAddressForAddress(address) UTF8String]);
    string sAddress = "开始发包" + string(cAddress);
//    vTLogD("1022","日志 DEBUG , time=%s, ts=%s", [[DebugPublicMethod onGetCurrentTime] UTF8String], sAddress.c_str());
    
    [self sendPing];
    
//    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
// A SimplePing delegate callback method.  We shut down our timer and the
// SimplePing object itself, which causes the runloop code to exit.
{
#pragma unused(error)
    NSLog(@"failed: %@", [self shortErrorFromError:error]);
    
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    [self onControlReceivePackageTimeinterval];
    self.pinger = nil;
    _item.bTestSpeedSuccess = NO;
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the send.
{
#pragma unused(pinger)
#pragma unused(packet)
    _item.startTime= [NSDate date];
    
    [self performSelector:@selector(onControlReceivePackageTimeinterval) withObject:nil afterDelay:5];
//    vTLogD("1022","日志 DEBUG , time=%s, 发送的packet序列号=%d", [[DebugPublicMethod onGetCurrentTime] UTF8String],(unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber));
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
// A SimplePing delegate callback method.  We just log the failure.
{
#pragma unused(pinger)
#pragma unused(packet)
#pragma unused(error)
    
    NSLog(@"#%u send failed: %@", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), [self shortErrorFromError:error]);
    NSString * number = [NSString stringWithFormat:@"发送失败的包序列号%u" ,(unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber)];
//    vTLogD("1022","日志 DEBUG , time=%s, ts=%s", [[DebugPublicMethod onGetCurrentTime] UTF8String], [number UTF8String]);
    self.pinger = nil;
    _item.bTestSpeedSuccess = NO;
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
#pragma unused(pinger)
#pragma unused(packet)
    NSLog(@"#%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );
    NSString * number = [NSString stringWithFormat:@"收到的包序列号%u" ,(unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber)];
//    vTLogD("1022","日志 DEBUG , time=%s, ts=%s", [[DebugPublicMethod onGetCurrentTime] UTF8String], [number UTF8String]);
    
    _item.endTime = [NSDate date];
    if(PingResultCallBack){
        PingResultCallBack([_item.endTime timeIntervalSince1970] - [_item.startTime timeIntervalSince1970]);
    }
    self.pinger = nil;
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    const ICMPHeader *  icmpPtr;
    
#pragma unused(pinger)
#pragma unused(packet)
    
    icmpPtr = [SimplePing icmpInPacket:packet];
    if (icmpPtr != NULL) {
        NSLog(@"#%u unexpected ICMP type=%u, code=%u, identifier=%u", (unsigned int) OSSwapBigToHostInt16(icmpPtr->sequenceNumber), (unsigned int) icmpPtr->type, (unsigned int) icmpPtr->code, (unsigned int) OSSwapBigToHostInt16(icmpPtr->identifier) );
    }
    else {
        NSLog(@"unexpected packet size=%zu", (size_t) [packet length]);
    }
    
//    NSString * number = [NSString stringWithFormat:@"收到的非顺序包的序列号%u" ,(unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber)];
//    vTLogD("1022","日志测试 DEBUG time=%s, ts=%s", [[DebugPublicMethod onGetCurrentTime] UTF8String], [number UTF8String]);
//    _item.endTime = [NSDate date];
//    self.pinger = nil;
}

- (void)onGetFastestIP:(NSArray * )ips{
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeStyle:NSDateFormatterFullStyle];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    for (int i= 0; i < ips.count ;i++) {
        NSString * ip = [ips objectAtIndex:i];
        serverItem * item = [[serverItem alloc]init];
        item.ip = ip;
        [self runWithHostName:item];
    }
}

- (void)setTimeoutBlock:(void (^)(NSString *))block pingResultBlock:(void (^)(float))pingBlock{
    TimeoutCallBack = block;
    PingResultCallBack = pingBlock;
}

@end


















