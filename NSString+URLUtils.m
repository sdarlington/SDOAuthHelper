//
//  NSString+URLUtils.m
//
//  Created by Stephen Darlington on 11/09/2010.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import "NSString+URLUtils.h"


@implementation NSString (URLUtils)

-(BOOL)isValidURL {
    NSURL* convurl = [NSURL URLWithString:self];
    return (convurl && convurl.host && convurl.scheme);
}

-(NSString*)URLEncodeWholeString {
    return [self URLEncodeWholeStringWithEscapeCharacters:@";/?:@&=+$,[]#!'()*"];
}

-(NSString*)URLEncodeWholeStringWithEscapeCharacters:(NSString*)toEscape {
    NSString* urlEnc = (NSString*) CFURLCreateStringByAddingPercentEscapes(
                                                                           kCFAllocatorDefault,
                                                                           (CFStringRef) self,
                                                                           NULL,
                                                                           (CFStringRef)toEscape,
                                                                           kCFStringEncodingUTF8
                                                                           );
    return [urlEnc autorelease];
}

-(NSString*)URLDecodeWholeString {
    NSString* urlDec = (NSString*) CFURLCreateStringByReplacingPercentEscapes (
                                                                               kCFAllocatorDefault,
                                                                               (CFStringRef) self,
                                                                               CFSTR("")
                                                                               );
    return [urlDec autorelease];
}

@end
