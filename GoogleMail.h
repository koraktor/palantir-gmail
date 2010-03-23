/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>
#import <Palantir/PalantirPlugin.h>
#import <WebKit/WebPolicyDelegate.h>
#import <WebKit/WebView.h>


@interface GoogleMail : PalantirPlugin <WebPolicyDecisionListener> {

    NSNumber       *actionInterval;
    NSTextField    *errorMessage;
    int             lastStatusCode;
    NSMutableArray *mails;
    NSImage        *newMailIcon;
    NSImage        *noMailIcon;
    NSMutableData  *responseData;
    NSString       *username;
    WebView        *webView;
    NSWindow       *window;

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
- (void)generateWindowContent;
- (NSString *)password;
- (void)setActionInterval:(NSNumber *)aValue;
- (void)setPassword:(NSString *)aPassword;
- (void)setUsername:(NSString *)aUsername;

@property (assign) IBOutlet NSTextField      *errorMessage;
@property (assign) IBOutlet WebView          *webView;
@property (assign, nonatomic) int             lastStatusCode; 
@property (nonatomic, retain) NSMutableArray *mails;
@property (nonatomic, retain) NSImage        *newMailIcon;
@property (nonatomic, retain) NSImage        *noMailIcon; 
@property (nonatomic, retain) NSString       *password;
@property (nonatomic, retain) NSMutableData  *responseData;
@property (nonatomic, retain) NSString       *username;

@end
