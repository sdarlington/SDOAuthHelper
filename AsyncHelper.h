//
//  AsyncHelper.h
//
//  Created by Stephen Darlington on 21/06/2009.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncHelper : NSObject {
    NSURLConnection* reqConnection;
    NSMutableData* receivedData;
    NSInteger status;
}

@property (nonatomic,assign) NSInteger status;

- (void) makeRequest:(NSString*)url;
- (void) makeRequestWithURLRequest:(NSURLRequest*)req;
- (void) asyncDownloadSuccessful;
- (void) asyncDownloadFailure:(NSError*)error;

@end
