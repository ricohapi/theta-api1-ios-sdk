/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "PtpConnection.h"
#import "PtpObject.h"

@interface ImageViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIProgressView* progressView;

- (IBAction)onCloseClicked:(id)sender;
- (void)getObject:(PtpConnection*)ptpConnection ptpObject:(PtpObject*)ptpObject;

@end
