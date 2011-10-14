//
//  SDOAuthHelper.m
//
//  Created by Stephen Darlington on 23/11/2009.
//  Copyright 2011 Wandle Software Limited. All rights reserved.
//

#import "SDOAuthHelper.h"
#import "hmac.h"
#import "Base64Transcoder.h"
#import "NSString+URLUtils.h"

@interface SDOAuthHelper ()

- (NSString*) nonce;
- (NSString*) timestamp;

@end

@implementation SDOAuthHelper

@synthesize consumerKey, sharedSecret, token, tokenSecret, session, expiresIn;

- (id) init {
    if ((self = [super init])) {
        self.consumerKey = nil;
        self.sharedSecret = nil;
        self.token = nil;
        self.session = nil;
        
        processing = nil;
        _delegate = nil;
    }
    return self;
}

- (id) initWithConsumerKey:(NSString*)key
                    secret:(NSString*)secret {
    if ((self = [super init])) {
        self.consumerKey = key;
        self.sharedSecret = secret;
        self.token = nil;
        self.session = nil;
    }
    return self;
}

- (id) initWithConsumerKey:(NSString*)key
                    secret:(NSString*)secret
                     token:(NSString*)oauth_token
               tokenSecret:(NSString*)oauth_token_secret
                   session:(NSString*)oauth_session_handle {
    if ((self = [super init])) {
        self.consumerKey = key;
        self.sharedSecret = secret;
        self.token = oauth_token;
        self.tokenSecret = oauth_token_secret;
        self.session = oauth_session_handle;
    }
    return self;
}

- (void) getRequestToken:(NSString*)url delegate:(id<SDOAuthHelperDelegate>) delegate {
    [self getRequestToken:url callback:@"oob" delegate:delegate];
}

- (void) getRequestToken:(NSString*)url callback:(NSString*)oauth_callback delegate:(id<SDOAuthHelperDelegate>) delegate {
    if (processing) {
        // Already inflight...
        [delegate oauthRequestTokenResponse:[NSError errorWithDomain:@"OAuth" code:100 userInfo:nil]
                                      token:nil
                                     secret:nil
                                    expires:nil
                                     others:nil];
        return;
    }
    
    _delegate = delegate;
    processing = _cmd;
    
    NSArray* params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                       [NSString stringWithFormat:@"oauth_nonce=%@", [self nonce]],
                       @"oauth_signature_method=HMAC-SHA1",
                       [NSString stringWithFormat:@"oauth_timestamp=%@", [self timestamp]],
                       @"oauth_version=1.0",
                       [NSString stringWithFormat:@"oauth_callback=%@", [oauth_callback URLEncodeWholeString] ],
                       nil];
    
    NSString* sig = [self addSignature:url parameters:params HTTPMethod:@"GET"];

    NSString* req = [NSString stringWithFormat:@"%@?%@", url, sig];
    [self makeRequest:req];
}

- (void) getToken:(NSString*)url verifier:(NSString*)oauth_verifier delegate:(id<SDOAuthHelperDelegate>) delegate {
    if (processing) {
        // Already inflight...
        [delegate oauthRequestAccessTokenResponse:[NSError errorWithDomain:@"OAuth" code:100 userInfo:nil]
                                            token:nil
                                           secret:nil
                                          session:nil
                                          expires:nil
                                           others:nil];
        return;
    }
    
    _delegate = delegate;
    processing = _cmd;
    
    NSArray* params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                                                @"oauth_signature_method=HMAC-SHA1",
                                                [NSString stringWithFormat:@"oauth_timestamp=%@", [self timestamp]],
                                                @"oauth_version=1.0",
                                                [NSString stringWithFormat:@"oauth_token=%@", self.token],
                                                [NSString stringWithFormat:@"oauth_nonce=%@", [self nonce]],
                                                [NSString stringWithFormat:@"oauth_verifier=%@", oauth_verifier],
                                                nil];
    
    NSString* sig = [self addSignature:url parameters:params HTTPMethod:@"GET"];
    
    NSString* req = [NSString stringWithFormat:@"%@?%@", url, sig];
    [self makeRequest:req];
}

- (void) getToken:(NSString*)url username:(NSString*)username password:(NSString*)password delegate:(id<SDOAuthHelperDelegate>) delegate {
    if (processing) {
        // Already inflight...
        [delegate oauthRequestAccessTokenResponse:[NSError errorWithDomain:@"OAuth" code:100 userInfo:nil]
                                            token:nil
                                           secret:nil
                                          session:nil
                                          expires:nil
                                           others:nil];
        return;
    }
    
    _delegate = delegate;
    processing = _cmd;

    NSArray* params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                       @"oauth_signature_method=HMAC-SHA1",
                       [NSString stringWithFormat:@"oauth_timestamp=%@", [self timestamp]],
                       @"oauth_version=1.0",
                       [NSString stringWithFormat:@"oauth_nonce=%@", [self nonce]],
                       [NSString stringWithFormat:@"x_auth_username=%@", [username URLEncodeWholeString]],
                       [NSString stringWithFormat:@"x_auth_password=%@", [password URLEncodeWholeString]],
                       @"x_auth_mode=client_auth",
                       nil];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    NSString* paramsOauth = [self addSignature:url parameters:params HTTPMethod:@"POST"];
    NSData *paramsData = [ NSData dataWithBytes:[paramsOauth UTF8String] length:[paramsOauth length] ];

    [theRequest setValue:[NSString stringWithFormat:@"%d", [paramsData length]] forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [theRequest setHTTPMethod:@"POST"];
    NSBundle* app = [NSBundle mainBundle];
    NSDictionary *infoDict = [app infoDictionary]; 
    NSString *myVersion = (NSString *)[infoDict valueForKey:@"CFBundleVersion"]; 
	[theRequest setValue:[@"iPhoneYummy/" stringByAppendingString:myVersion] forHTTPHeaderField:@"User-Agent"];
	[theRequest setHTTPBody:paramsData];
    
    [self makeRequestWithURLRequest:theRequest];
}

- (void) getToken:(NSString*)url delegate:(id<SDOAuthHelperDelegate>) delegate {
    if (processing) {
        // Already inflight...
        [delegate oauthRequestAccessTokenResponse:[NSError errorWithDomain:@"OAuth" code:100 userInfo:nil]
                                            token:nil
                                           secret:nil
                                          session:nil
                                          expires:nil
                                           others:nil];
        return;
    }
    
    _delegate = delegate;
    processing = _cmd;
    
    NSArray* params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                       @"oauth_signature_method=HMAC-SHA1",
                       [NSString stringWithFormat:@"oauth_timestamp=%@", [self timestamp]],
                       @"oauth_version=1.0",
                       [NSString stringWithFormat:@"oauth_token=%@", self.token],
                       [NSString stringWithFormat:@"oauth_session_handle=%@", self.session],
                       [NSString stringWithFormat:@"oauth_nonce=%@", [self nonce]],
                       nil];
    
    NSString* sig = [self addSignature:url parameters:params HTTPMethod:@"GET"];
    
    NSString* req = [NSString stringWithFormat:@"%@?%@", url, sig];
    [self makeRequest:req];
}

- (NSString*) addSignature:(NSString*)url parameters:(NSArray*)params HTTPMethod:(NSString*)method {
    NSArray* sorted = [params sortedArrayUsingSelector:@selector(compare:)];
    NSString* stringParams = [sorted componentsJoinedByString:@"&"];

    return [NSString stringWithFormat:@"%@&oauth_signature=%@", stringParams, [self getSignature:url parameters:params HTTPMethod:method]];
}

- (NSString*) getSignature:(NSString*)url parameters:(NSArray*)params HTTPMethod:(NSString*)method {
    NSArray* sorted = [params sortedArrayUsingSelector:@selector(compare:)];
    NSString* stringParams = [sorted componentsJoinedByString:@"&"];

    NSString* base = [NSString stringWithFormat:@"%@&%@&%@", method, [url URLEncodeWholeString], [stringParams URLEncodeWholeString]];
    NSString* secret = [NSString stringWithFormat:@"%@&%@", self.sharedSecret, (self.tokenSecret == nil) ? @"" : self.tokenSecret];
    
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *textData = [base dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[20];
	hmac_sha1((unsigned char *)[textData bytes], [textData length], (unsigned char *)[secretData bytes], [secretData length], result);
	
	// Base64 Encoding
	char base64Result[32];
	size_t theResultLength = 32;
	Base64EncodeData(result, 20, base64Result, &theResultLength);
	NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
	NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
        
    NSString* paramList = [base64EncodedResult URLEncodeWholeString];
    [base64EncodedResult release];
    
    return paramList;
}

- (NSString*) getURLWithOAuthParams:(NSString*)sourceURL withParameters:(NSArray*)params HTTPMethod:(NSString*)method {
    NSMutableArray* oauthParams = [NSMutableArray arrayWithObjects:
                                   [NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                                   [NSString stringWithFormat:@"oauth_token=%@", self.token],
                                   @"oauth_signature_method=HMAC-SHA1",
                                   [NSString stringWithFormat:@"oauth_nonce=%@", [self nonce]],
                                   [NSString stringWithFormat:@"oauth_timestamp=%@", [self timestamp]],
                                   @"oauth_version=1.0", nil];
    [oauthParams addObjectsFromArray:params];
    NSString* retv = [self addSignature:sourceURL parameters:oauthParams HTTPMethod:method];
    return retv;
}

- (NSString*) getOAuthAuthorizeHeader:(NSString*)sourceURL withParameters:(NSArray*)params HTTPMethod:(NSString*)method {
    NSString* nonce = [self nonce];
    NSString* time = [self timestamp];
    NSMutableArray* oauthParams = [NSMutableArray arrayWithObjects:
                                   [NSString stringWithFormat:@"oauth_consumer_key=%@", self.consumerKey],
                                   [NSString stringWithFormat:@"oauth_token=%@", self.token],
                                   @"oauth_signature_method=HMAC-SHA1",
                                   [NSString stringWithFormat:@"oauth_nonce=%@", nonce],
                                   [NSString stringWithFormat:@"oauth_timestamp=%@", time],
                                   @"oauth_version=1.0", nil];
    [oauthParams addObjectsFromArray:params];
    NSString* sig = [self getSignature:sourceURL parameters:oauthParams HTTPMethod:method];
    NSString* header = [NSString stringWithFormat:@"OAuth realm=\"%@\",oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_version=\"1.0\",oauth_signature=\"%@\"",
                        @"yahooapis.com", self.consumerKey, nonce, time, self.token, sig];
    return header;
}

- (void) asyncDownloadSuccessful {
    if (self.status != 200) {
        NSError* error = [NSError errorWithDomain:@"OAuth" code:102 userInfo:[NSDictionary dictionaryWithObject:@"Invalid username or password" forKey:@"ErrorString"]];
        if (processing == @selector(getRequestToken:callback:delegate:)) {
            [_delegate oauthRequestTokenResponse:error
                                           token:nil
                                          secret:nil
                                         expires:nil
                                          others:nil];
        }
        else if (processing == @selector(getToken:verifier:delegate:) ||
                 processing == @selector(getToken:delegate:) ||
                 processing == @selector(getToken:username:password:delegate:)) {
            [_delegate oauthRequestAccessTokenResponse:error
                                                 token:nil
                                                secret:nil
                                               session:nil
                                               expires:nil
                                                others:nil];
        }
        
        _delegate = nil;
        processing = nil;
        return;
    }
    
    NSString* resp = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSArray* paramStrings = [resp componentsSeparatedByString:@"&"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:[paramStrings count]];
    for (NSString* a in paramStrings) {
        NSArray* vals = [a componentsSeparatedByString:@"="];
        [params setObject:([vals count] > 1) ? [vals objectAtIndex:1] : nil forKey:[vals objectAtIndex:0]];
    }
    [resp release];
    
    if ([params objectForKey:@"oauth_problem"]) {
        NSError* error = [NSError errorWithDomain:@"OAuth" code:101 userInfo:[NSDictionary dictionaryWithObject:[params objectForKey:@"oauth_problem"] forKey:@"ErrorString"]];
        if (processing == @selector(getRequestToken:callback:delegate:)) {
            [_delegate oauthRequestTokenResponse:error
                                           token:nil
                                          secret:nil
                                         expires:nil
                                          others:nil];
        }
        else if (processing == @selector(getToken:verifier:delegate:) ||
                 processing == @selector(getToken:delegate:) ||
                 processing == @selector(getToken:username:password:delegate:)) {
            [_delegate oauthRequestAccessTokenResponse:error
                                                 token:nil
                                                secret:nil
                                               session:nil
                                               expires:nil
                                                others:nil];
        }
        
        _delegate = nil;
        processing = nil;
        [params release];
        return;
    }
    
    if (processing == @selector(getRequestToken:callback:delegate:)) {
        processing = nil;
        
        self.token = [params objectForKey:@"oauth_token"];
        self.tokenSecret = [params objectForKey:@"oauth_token_secret"];
        self.expiresIn = [[NSDate date] addTimeInterval:[[params objectForKey:@"oauth_expires_in"] doubleValue]];
        
        [_delegate oauthRequestTokenResponse:nil
                                       token:self.token
                                      secret:self.tokenSecret
                                     expires:self.expiresIn
                                      others:params];
        _delegate = nil;
    }
    else if (processing == @selector(getToken:verifier:delegate:) || processing == @selector(getToken:delegate:) ||
             processing == @selector(getToken:username:password:delegate:)) {
        processing = nil;
        
        self.token = [params objectForKey:@"oauth_token"];
        self.session = [params objectForKey:@"oauth_session_handle"];
        self.tokenSecret = [params objectForKey:@"oauth_token_secret"];
        self.expiresIn = [[NSDate date] addTimeInterval:[[params objectForKey:@"oauth_expires_in"] doubleValue]];
        
        [_delegate oauthRequestAccessTokenResponse:nil
                                             token:self.token
                                            secret:self.tokenSecret
                                           session:self.session
                                           expires:self.expiresIn
                                            others:params];
        _delegate = nil;
    }
    else {
        NSLog (@"Um, we shouldn't be here...");
    }
    [params release];
}

- (void) asyncDownloadFailure:(NSError*)error {
    
}

- (void) logout {
    self.token = nil;
    self.tokenSecret = nil;
    self.session = nil;
}

- (NSString*) nonce {
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    NSString* retv = (NSString*) CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    
    return [retv autorelease];
}

- (NSString*) timestamp {
    return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

@end
