//
//  Mail.m
//  Palantir Google Mail
//
//  Created by Sebastian Staudt on 12.03.10.
//  Copyright 2010 AG der Dillinger Hüttenwerke. All rights reserved.
//

#import "Mail.h"


@implementation Mail

@synthesize atomId, authors, date, subject, summary, url;

+ (Mail *)mailFromAtomNode:(NSXMLNode *)aNode {
    Mail *mail = [[Mail alloc] init];
    
    NSDateFormatter *rfc1123DateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [rfc1123DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
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
