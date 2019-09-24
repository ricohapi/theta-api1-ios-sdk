/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PtpIpObjectInfo.h"

@interface PtpObject : NSObject

@property (readonly) UIImage* thumbnail;
@property (readonly) PtpIpObjectInfo* objectInfo;

- (id)initWithObjectInfo:(PtpIpObjectInfo*)objectInfo thumbnail:(UIImage*)thumbnail;

@end
