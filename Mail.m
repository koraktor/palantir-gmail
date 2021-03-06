/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import "Mail.h"

static NSDateFormatter *rfc1123DateFormatter;

@implementation Mail

@synthesize atomId, authors, date, subject, summary, url;

+ (Mail *)mailFromAtomNode:(NSXMLNode *)aNode {
    if(rfc1123DateFormatter == nil) {
        rfc1123DateFormatter = [[NSDateFormatter alloc] init];
        [rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [rfc1123DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }

    Mail *mail = [[Mail alloc] init];
    
    NSError *xmlError;
    
    mail.atomId  = [[[aNode nodesForXPath:@"id" error:&xmlError] objectAtIndex:0] stringValue];
    [mail.atomId retain];
    mail.date    = [rfc1123DateFormatter dateFromString:[[[aNode nodesForXPath:@"issued" error:&xmlError] objectAtIndex:0] stringValue]];
    [mail.date retain];
    mail.subject = [[[aNode nodesForXPath:@"title" error:&xmlError] objectAtIndex:0] stringValue];
    [mail.subject retain];
    mail.summary = [[[aNode nodesForXPath:@"summary" error:&xmlError] objectAtIndex:0] stringValue];
    [mail.summary retain];
    mail.url     = [NSURL URLWithString:[[[[aNode nodesForXPath:@"link" error:&xmlError] objectAtIndex:0] attributeForName:@"href"] stringValue]];
    [mail.url retain];
    
    return mail;
}

@end
