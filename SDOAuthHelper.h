//
//  SDOAuthHelper.h
//
//  Created by Stephen Darlington on 23/11/2009.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHelper.h"

@protocol SDOAuthHelperDelegate

- (void) oauthRequestTokenResponse:(NSError*)error
                             token:(NSString*)oauth_token
                            secret:(NSString*)oauth_token_secret
                           expires:(NSDate*)oauth_expires_in
                            others:(NSDictionary*)misc;

- (void) oauthRequestAccessTokenResponse:(NSError*)error
                                   token:(NSString*)oauth_token
                                  secret:(NSString*)oauth_token_secret
                                 session:(NSString*)oauth_session_handle
                                 expires:(NSDate*)oauth_expires_in
                                  others:(NSDictionary*)misc;

@end


@interface SDOAuthHelper : AsyncHelper {
    NSString* consumerKey;
    NSString* sharedSecret;
    
    NSString* token;
    NSString* tokenSecret;
    NSString* session;
    NSDate* expiresIn;
    
    SEL processing;
    id<SDOAuthHelperDelegate> _delegate;
}

@property (nonatomic, retain) NSString* consumerKey;
@property (nonatomic, retain) NSString* sharedSecret;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* tokenSecret;
@property (nonatomic, retain) NSString* session;
@property (nonatomic, retain) NSDate* expiresIn;

// Used when logging in
- (id) initWithConsumerKey:(NSString*)key
                    secret:(NSString*)secret;

// Used when we're already logged in
- (id) initWithConsumerKey:(NSString*)key
                    secret:(NSString*)secret
                     token:(NSString*)oauth_token
               tokenSecret:(NSString*)oauth_token_secret
                   session:(NSString*)oauth_session_handle;

- (void) getRequestToken:(NSString*)url delegate:(id<SDOAuthHelperDelegate>) delegate;
- (void) getRequestToken:(NSString*)url callback:(NSString*)oauth_callback delegate:(id<SDOAuthHelperDelegate>) delegate;

// Used when we're logging in
- (void) getToken:(NSString*)url verifier:(NSString*)oauth_verifier delegate:(id<SDOAuthHelperDelegate>) delegate;
- (void) getToken:(NSString*)url username:(NSString*)username password:(NSString*)password delegate:(id<SDOAuthHelperDelegate>) delegate;

// Used when we're already logged in
- (void) getToken:(NSString*)url delegate:(id<SDOAuthHelperDelegate>) delegate;

- (NSString*) addSignature:(NSString*)url parameters:(NSArray*)params HTTPMethod:(NSString*)method;
- (NSString*) getSignature:(NSString*)url parameters:(NSArray*)params HTTPMethod:(NSString*)method;
- (NSString*) getOAuthAuthorizeHeader:(NSString*)sourceURL withParameters:(NSArray*)params HTTPMethod:(NSString*)method;

- (NSString*) getURLWithOAuthParams:(NSString*)sourceURL withParameters:(NSArray*)params HTTPMethod:(NSString*)method;

- (void) logout;

@end
