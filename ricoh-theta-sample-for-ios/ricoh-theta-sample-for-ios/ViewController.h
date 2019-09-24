/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField* ipField;
@property (nonatomic, strong) IBOutlet UIButton* connectButton;
@property (nonatomic, strong) IBOutlet UITableView* contentsView;
@property (nonatomic, strong) IBOutlet UITextView* logView;

@end
