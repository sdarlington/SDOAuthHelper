//
//  AsyncHelper.m
//
//  Created by Stephen Darlington on 21/06/2009.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import "AsyncHelper.h"


@implementation AsyncHelper

@synthesize status;

- (void) makeRequest:(NSString*)url {
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    [self makeRequestWithURLRequest:theRequest];
}

- (void) makeRequestWithURLRequest:(NSURLRequest*)req {
    // create the connection with the request
    // and start loading the data
    reqConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (reqConnection) {
        // Create the NSMutableData that will hold
        // the received data
        // receivedData is declared as a method instance elsewhere
        receivedData = [[NSMutableData alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        // inform the user that the download could not be made
        [self asyncDownloadFailure:[NSError errorWithDomain:@"AsyncHelper" code:100 userInfo:nil]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.status = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self asyncDownloadFailure:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self asyncDownloadSuccessful];

    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

- (void) asyncDownloadSuccessful {
    @throw [NSException exceptionWithName:@"AsyncHelper" reason:@"No implementation" userInfo:nil];
}

- (void) asyncDownloadFailure:(NSError*)error {
    @throw [NSException exceptionWithName:@"AsyncHelper" reason:@"No implementation" userInfo:nil];
}


@end
