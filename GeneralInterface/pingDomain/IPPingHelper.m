//
//  IPPingHelper.m
//  GeneralInterface
//
//  Created by mac  on 14-8-14.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "IPPingHelper.h"
#include <netdb.h>


@implementation IPPingHelper

+ (NSString *)getAddressForAddress:(NSData *)address{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr),NULL, 0, NI_NUMERICHOST);
        //        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
        }
    }
    
    return result;
}


@end
