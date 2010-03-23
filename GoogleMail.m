/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */
 
#import <WebKit/DOMHTMLDocument.h>
#import <WebKit/WebFrame.h>

#import "GoogleMail.h"
#import "Mail.h"


@implementation GoogleMail

@synthesize errorMessage, lastStatusCode, mails, newMailIcon, noMailIcon,
            responseData, username, webView;

- (void)awakeFromNib {
    [WebView registerURLSchemeAsLocal:@"palantir"];

    actionInterval = [self settingWithName:@"actionInterval"];
    if(actionInterval == nil) {
        actionInterval = [NSNumber numberWithInt:180];
    }
    self.responseData = [NSMutableData data];
    self.username = [self settingWithName:@"username"];
    if(username == nil) {
        username = @"";
    }
    
    self.newMailIcon = [[NSImage alloc] initWithContentsOfFile:[self.bundle pathForResource:@"new-mail" ofType:@"png"]];
    [self.newMailIcon setSize:NSMakeSize(20, 16)];
    
    self.noMailIcon = [[NSImage alloc] initWithContentsOfFile:[self.bundle pathForResource:@"no-mail" ofType:@"png"]];
    [self.noMailIcon setSize:NSMakeSize(20, 16)];
    
    webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 400, 50)];
    [webView setAutoresizingMask:NSViewHeightSizable];
    [webView setDrawsBackground:NO];
    [webView setFrameLoadDelegate:self];
    [webView setPolicyDelegate:self];

    [super awakeFromNib];

    [self setStatusItemImage:noMailIcon];
    [self setStatusItemTitle:nil];
    [self setAttachedWindowView:webView];

    [self action];
}

- (void)action {
    if(self.username != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mail.google.com/mail/feed/atom"]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (NSTimeInterval)actionInterval {
    return [actionInterval intValue];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"Trying to authenticate with username \"%@\" and password \"%@\".", [self username], [self password]);
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:[self username]
                                                 password:[self password]
                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        [self.errorMessage setHidden:false];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
} 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData data] retain];
    
    if([response class] == [NSHTTPURLResponse class]) {
        self.lastStatusCode = [(NSHTTPURLResponse*) response statusCode];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(self.lastStatusCode == 200) {
        NSError *xmlError;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:self.responseData
                                                             options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                               error:&xmlError];
                                            
        if(document != nil) {
            int unreadCount = [[[[document nodesForXPath:@"feed/fullcount" error:&xmlError] objectAtIndex:0] stringValue] intValue];
            if(unreadCount == 0)  {
                [self setStatusItemImage:noMailIcon];
                [self setStatusItemTitle:nil];                
            } else {
                [self setStatusItemImage:newMailIcon];
                [self setStatusItemTitle:[NSString stringWithFormat:@"%d", unreadCount]];
            }
            
            self.mails = [NSMutableArray arrayWithCapacity:unreadCount];
            
            NSArray *unreadMails = [document nodesForXPath:@"feed/entry" error:&xmlError];
            for(NSXMLNode *unreadMail in unreadMails) {                                
                [self.mails addObject:[Mail mailFromAtomNode:unreadMail]];
            }
        }
    }
    
    [self.responseData setLength:0];
    [self.mails retain];
    [self generateWindowContent];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)download {}

- (void)generateWindowContent {
    NSMutableString *mailsHtml = [NSMutableString string];

    for(Mail *mail in self.mails) {
        [mailsHtml appendString:[NSString stringWithFormat:@"<a href=\"%@\"><div id=\"mail-%@\"><div class=\"subject\" title=\"%@\">%@</div>%@</div></a>", mail.url, mail.atomId, mail.date, mail.subject, mail.summary]];
    }

    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link href=\"./default.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" /></head><body><div id=\"content\">%@</div></body></html>", mailsHtml];
    
    [[self.webView mainFrame] loadHTMLString:htmlString baseURL:[self.bundle resourceURL]];
}

- (void)ignore {}

- (NSString *)password {
    return [self passwordForService:@"Google Mail" andAccount:self.username];
}

- (void)setActionInterval:(NSNumber *)aValue {
    switch([aValue intValue]) {
        case 0:
            actionInterval = [NSNumber numberWithInt:30];
            break;
        case 1:
            actionInterval = [NSNumber numberWithInt:60];
            break;
        case 2:
            actionInterval = [NSNumber numberWithInt:180];
            break;
        case 3:
            actionInterval = [NSNumber numberWithInt:300];
            break;
        default:
            actionInterval = [NSNumber numberWithInt:600];
            break;
    }
    
    [self setSettingWithName:@"actionInterval" toValue:actionInterval];
}

- (void)setPassword:(NSString *)aPassword {
    [self setPasswordForService:@"Google Mail" andAccount:self.username to:aPassword];
    
    [self.errorMessage setHidden:true];
    [self action];
}

- (void)setUsername:(NSString *)aUsername {
    username = aUsername;
    [self setSettingWithName:@"username" toValue:aUsername];
}

- (void)use {}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener {
    if(![[request URL] isFileURL]) {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    int htmlHeight = ((DOMHTMLDocument *)[frame DOMDocument]).height;
    NSLog(@"HTML height %d", htmlHeight);
    [webView setFrame:NSMakeRect(0, 0, 400, htmlHeight)];    
}

- (NSView *)windowView {
    return webView;
}

@end
