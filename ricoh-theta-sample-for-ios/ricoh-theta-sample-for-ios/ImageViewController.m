/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import "ImageViewController.h"
#import "RicohEXIF.h"
#import "ExifTags.h"

@interface ImageViewController ()
{
    PtpObject* _ptpObject;
}
@end

@implementation ImageViewController

- (void)appendLog:(NSString*)text
{
    [_textView setText:[NSString stringWithFormat:@"%@%@\n", _textView.text, text]];
    [_textView scrollRangeToVisible:NSMakeRange([_textView.text length], 0)];
}

#pragma mark - UI events

- (void)onCloseClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PTP/IP Operation

- (void)getObject:(PtpConnection *)ptpConnection ptpObject:(PtpObject *)ptpObject
{
    _ptpObject = ptpObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = 0.0;
        _progressView.hidden = NO;
    });
    
    [ptpConnection operateSession:^(PtpIpSession *session) {
        // This block is running at PtpConnection#gcd thread.
        
        NSMutableData* imageData = [NSMutableData data];
        uint32_t objectHandle = (uint32_t)_ptpObject.objectInfo.object_handle;
        __block float total = 0.0;
        
        // Get primary image that was resized to 2048x1024.
        BOOL result = [session getResizedImageObject:objectHandle
                                               width:2048
                                              height:1024
                                         onStartData:^(NSUInteger totalLength) {
                                             // Callback before object-data reception.
                                             NSLog(@"getObject(0x%08x) will received %zd bytes.", objectHandle, totalLength);
                                             total = (float)totalLength;
                                             
                                         } onChunkReceived:^BOOL(NSData *data) {
                                             // Callback for each chunks.
                                             [imageData appendData:data];
                                             
                                             // Update progress.
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 _progressView.progress = (float)imageData.length / total;
                                             });
                                             
                                             // Continue to receive.
                                             return YES;
                                         }];
        _progressView.progress = 1.0;
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _progressView.hidden = YES;
            });
            return;
        }
        UIImage* image = [UIImage imageWithData:imageData];
        
        // Parse EXIF data, it contains the data to correct the tilt.
        RicohEXIF* exif = [[RicohEXIF alloc] initWithNSData:imageData];
        
        // If there is no information, yaw, pitch and roll method returns NaN.
        NSString* tiltInfo = [NSString stringWithFormat:@"yaw:%0.1f pitch:%0.1f roll:%0.1f",
                              exif.yaw,
                              exif.pitch,
                              exif.roll];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressView.hidden = YES;
            _imageView.image = image;
            _imageView.alpha = 1.0;
            [self appendLog:tiltInfo];
        });
    }];
}

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _progressView.hidden = YES;
    if (_imageView.image==nil) {
        _imageView.image = _ptpObject.thumbnail; // preview
        _imageView.alpha = 0.5;
    }
    [self appendLog:_ptpObject.objectInfo.description];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _textView.text = nil;
    _imageView.image = nil;
    _ptpObject = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _textView.text = nil;
    _imageView.image = nil;
    _ptpObject = nil;
}

@end
