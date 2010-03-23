/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>


@interface Mail : NSObject {

    NSString     *atomId;
    NSDictionary *authors;
    NSDate       *date;
    NSString     *subject;
    NSString     *summary;
    NSURL        *url;

}

+ (Mail *)mailFromAtomNode:(NSXMLNode *)aNode;

@property (assign, nonatomic) NSString     *atomId;
@property (assign, nonatomic) NSDictionary *authors;
@property (assign, nonatomic) NSDate       *date;
@property (assign, nonatomic) NSString     *subject;
@property (assign, nonatomic) NSString     *summary;
@property (assign, nonatomic) NSURL        *url;

@end
