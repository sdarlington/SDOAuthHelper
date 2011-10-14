//
//  NSString+URLUtils.h
//
//  Created by Stephen Darlington on 11/09/2010.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (URLUtils)

-(BOOL)isValidURL;

-(NSString*)URLEncodeWholeString;
-(NSString*)URLEncodeWholeStringWithEscapeCharacters:(NSString*)toEscape;

-(NSString*)URLDecodeWholeString;

@end
