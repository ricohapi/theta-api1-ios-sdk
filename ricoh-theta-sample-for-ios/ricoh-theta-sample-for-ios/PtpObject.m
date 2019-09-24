/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import "PtpObject.h"

@implementation PtpObject

@synthesize objectInfo = _objectInfo;
@synthesize thumbnail = _thumbnail;

- (id)initWithObjectInfo:(PtpIpObjectInfo*)objectInfo thumbnail:(UIImage*)thumbnail
{
    self = [super init];
    if (self) {
        _objectInfo = objectInfo;
        _thumbnail = thumbnail;
    }
    return self;    
}

@end
