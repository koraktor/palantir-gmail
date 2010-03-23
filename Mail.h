//
//  Mail.h
//  Palantir Google Mail
//
//  Created by Sebastian Staudt on 12.03.10.
//  Copyright 2010 AG der Dillinger Hüttenwerke. All rights reserved.
//

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
