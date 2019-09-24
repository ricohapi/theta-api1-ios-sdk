/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import "ViewController.h"
#import "TableCell.h"
#import "ImageViewController.h"
#import "PtpConnection.h"
#import "PtpLogging.h"
#import "PtpObject.h"

inline static void dispatch_async_main(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

@interface ViewController () <PtpIpEventListener, UITableViewDelegate, UITableViewDataSource>
{
    PtpConnection* _ptpConnection;
    NSMutableArray* _objects;
    PtpIpStorageInfo* _storageInfo;
    NSUInteger _batteryLevel;
}
@end

@implementation ViewController

- (void)appendLog:(NSString*)text
{
    [_logView setText:[NSString stringWithFormat:@"%@%@\n", _logView.text, text]];
    [_logView scrollRangeToVisible:NSMakeRange([_logView.text length], 0)];
}

#pragma mark - PtpIpEventListener delegates.

-(void)ptpip_eventReceived:(int)code :(uint32_t)param1 :(uint32_t)param2 :(uint32_t)param3
{
    // PTP/IP-Event callback.
    // This method is running at PtpConnection#gcd thread.
    switch (code) {
        default:
        {
            dispatch_async_main(^{
                [self appendLog:[NSString stringWithFormat:@"Event(0x%04x) received", code]];
            });
        }
            break;
            
        case PTPIP_OBJECT_ADDED:
        {
            // It will be receive when the camera has taken a new photo.
            dispatch_async_main(^{
                [self appendLog:[NSString stringWithFormat:@"Object added Event(0x%04x) - 0x%08x", code, param1]];
            });
            [_ptpConnection operateSession:^(PtpIpSession *session) {
                [_objects addObject:[self loadObject:param1 session:session]];
                NSIndexPath* pos = [NSIndexPath indexPathForRow:_objects.count-1 inSection:1];
                dispatch_async_main(^{
                    [_contentsView beginUpdates];
                    [_contentsView insertRowsAtIndexPaths:@[pos]
                                         withRowAnimation:UITableViewRowAnimationRight];
                    [_contentsView endUpdates];
                });
            }];
        }
            break;
    }
}

-(void)ptpip_socketError:(int)err
{
    // socket error callback.
    // This method is running at PtpConnection#gcd thread.
    
    // If libptpip closed the socket, `closed` is non-zero.
    BOOL closed = PTP_CONNECTION_CLOSED(err);
    
    // PTPIP_PROTOCOL_*** or POSIX error number (errno()).
    err = PTP_ORIGINAL_PTPIPERROR(err);
    
    NSArray* errTexts = @[@"Socket closed",              // PTPIP_PROTOCOL_SOCKET_CLOSED
                          @"Brocken packet",             // PTPIP_PROTOCOL_BROCKEN_PACKET
                          @"Rejected",                   // PTPIP_PROTOCOL_REJECTED
                          @"Invalid session id",         // PTPIP_PROTOCOL_INVALID_SESSION_ID
                          @"Invalid transaction id.",    // PTPIP_PROTOCOL_INVALID_TRANSACTION_ID
                          @"Unrecognided command",       // PTPIP_PROTOCOL_UNRECOGNIZED_COMMAND
                          @"Invalid receive state",      // PTPIP_PROTOCOL_INVALID_RECEIVE_STATE
                          @"Invalid data length",        // PTPIP_PROTOCOL_INVALID_DATA_LENGTH
                          @"Watchdog expired",           // PTPIP_PROTOCOL_WATCHDOG_EXPIRED
                          ];
    NSString* desc;
    if ((PTPIP_PROTOCOL_SOCKET_CLOSED<=err) && (err<=PTPIP_PROTOCOL_WATCHDOG_EXPIRED)) {
        desc = [errTexts objectAtIndex:err-PTPIP_PROTOCOL_SOCKET_CLOSED];
    } else {
        desc = [NSString stringWithUTF8String:strerror(err)];
    }
    
    dispatch_async_main(^{
        [self appendLog:[NSString stringWithFormat:@"socket error(0x%X,closed=%@).\n--- %@", err, closed? @"YES": @"NO", desc]];
        if (closed) {
            [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            [_objects removeAllObjects];
            [_contentsView reloadData];
        }
    });
}


#pragma mark - UI events.

- (void)onConnetClicked:(id)sender
{
    [_ipField resignFirstResponder];
    
    if ([_ptpConnection connected]) {
        [self disconnect];
    } else {
        [self connect];
    }
}

- (IBAction)onCaptureClicked:(id)sender
{
    [_ptpConnection operateSession:^(PtpIpSession *session)
     {
         // This block is running at PtpConnection#gcd thread.
         BOOL rtn = [session initiateCapture];
         dispatch_async_main(^{
             [self appendLog:[NSString stringWithFormat:@"execShutter[rtn:%d]", rtn]];
         });
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    id d = [segue destinationViewController];
    if ([d isKindOfClass:[ImageViewController class]]) {
        ImageViewController* dest = (ImageViewController*)d;
        TableCell* cell = (TableCell*)sender;
        PtpObject* object = [_objects objectAtIndex:cell.objectIndex];
        [dest getObject:_ptpConnection ptpObject:object];
    }
}

#pragma mark - PTP/IP Operations.

- (void)connect
{
    [self appendLog:[NSString stringWithFormat:@"connecting %@...", _ipField.text]];
    
    // Setup `target IP`(camera IP).
    // Product default is "192.168.1.1".
    [_ptpConnection setTargetIp:_ipField.text];
    
    // Connect to target.
    [_ptpConnection connect:^(BOOL connected) {
        // "Connect" and "OpenSession" completion callback.
        // This block is running at PtpConnection#gcd thread.
        
        if (connected) {
            // "Connect" is succeeded.
            dispatch_async_main(^{
                [self appendLog:@"connected."];
                [_connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            });
            
            // Start enum objects.
            [self enumObjects];
            
        } else {
            // "Connect" is failed.
            // "-(void)ptpip_socketError:(int)err" will run later than here.
            dispatch_async_main(^{
                [self appendLog:@"connect failed."];
            });
        }
    }];
}

- (void)disconnect
{
    [self appendLog:@"disconnecting..."];
    
    [_ptpConnection close:^{
        // "CloseSession" and "Close" completion callback.
        // This block is running at PtpConnection#gcd thread.
        
        dispatch_async_main(^{
            [self appendLog:@"disconnected."];
            [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            [_objects removeAllObjects];
            [_contentsView reloadData];
        });
    }];
}

- (void)enumObjects
{
    [_objects removeAllObjects];

    [_ptpConnection getDeviceInfo:^(const PtpIpDeviceInfo* info) {
        // "GetDeviceInfo" completion callback.
        // This block is running at PtpConnection#gcd thread.
        
        dispatch_async_main(^{
            [self appendLog:[NSString stringWithFormat:@"DeviceInfo:%@", info]];
        });
        
    }];
    
    [_ptpConnection operateSession:^(PtpIpSession *session) {
        // This block is running at PtpConnection#gcd thread.
        
        // Setting the RICOH THETA's clock.
        // 'setDateTime' convert from specified date/time to local-time, and send to RICOH THETA.
        // RICOH THETA work with local-time, without timezone.
        [session setDateTime:[NSDate dateWithTimeIntervalSinceNow:0]];
        
        // Get storage information.
        _storageInfo = [session getStorageInfo];
        
        // Get Battery level.
        _batteryLevel = [session getBatteryLevel];
        
        // Get object handles for primary images.
        NSArray* objectHandles = [session getObjectHandles];
        dispatch_async_main(^{
            [self appendLog:[NSString stringWithFormat:@"getObjectHandles() recevied %zd handles.", objectHandles.count]];
        });
        
        // Get object informations and thumbnail images for each primary images.
        for (NSNumber* it in objectHandles) {
            uint32_t objectHandle = (uint32_t)it.integerValue;
            [_objects addObject:[self loadObject:objectHandle session:session]];
        }
        dispatch_async_main(^{
            [_contentsView reloadData];
        });
    }];
}

- (PtpObject*)loadObject:(uint32_t)objectHandle session:(PtpIpSession*)session
{
    // This method MUST be running at PtpConnection#gcd thread.
    
    // Get object informations.
    // It containes filename, capture-date and etc.
    PtpIpObjectInfo* objectInfo = [session getObjectInfo:objectHandle];
    if (!objectInfo) {
        dispatch_async_main(^{
            [self appendLog:[NSString stringWithFormat:@"getObjectInfo(0x%08x) failed.", objectHandle]];
        });
        return nil;
    }
    
    UIImage* thumb;
    if (objectInfo.object_format==PTPIP_FORMAT_JPEG) {
        // Get thumbnail image.
        NSMutableData* thumbData = [NSMutableData data];
        BOOL result = [session getThumb:objectHandle
                            onStartData:^(NSUInteger totalLength) {
                                // Callback before thumb-data reception.
                                NSLog(@"getThumb(0x%08x) will received %zd bytes.", objectHandle, totalLength);
                                
                            } onChunkReceived:^BOOL(NSData *data) {
                                // Callback for each chunks.
                                [thumbData appendData:data];
                                
                                // Continue to receive.
                                return YES;
                            }];
        if (!result) {
            dispatch_async_main(^{
                [self appendLog:[NSString stringWithFormat:@"getThumb(0x%08x) failed.", objectHandle]];
            });
            thumb = [UIImage imageNamed:@"nothumb.png"];
        } else {
            thumb = [UIImage imageWithData:thumbData];
        }
    } else {
        thumb = [UIImage imageNamed:@"nothumb.png"];
    }
    return [[PtpObject alloc] initWithObjectInfo:objectInfo thumbnail:thumb];
}



#pragma mark - UITableViewDataSource delegates.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [_ptpConnection connected] ? 1: 0;
    }
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TableCell* cell;

    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cameraInfo"];
        cell.textLabel.text = [NSString stringWithFormat:@"%d[shots] %lld/%lld[MB] free",
                               _storageInfo.free_space_in_images,
                               _storageInfo.free_space_in_bytes/1000/1000,
                               _storageInfo.max_capacity/1000/1000];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"BATT %zd %%", _batteryLevel];
    } else {
        // NSDateFormatter to display photographing date.
        // You MUST specify `[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]`
        // to display photographing date('PtpIpObjectInfo#capture_date') in the local time.
        // As a result, 'PtpIpObjectInfo#capture_date' and 'kCGImagePropertyExifDateTimeOriginal' will match.
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterMediumStyle];

        PtpObject* obj = [_objects objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", obj.objectInfo.filename];
        cell.detailTextLabel.text = [df stringFromDate:obj.objectInfo.capture_date];
        cell.imageView.image = obj.thumbnail;
        cell.objectIndex = (uint32_t)indexPath.row;
    }
    return cell;
}

#pragma mark - Life cycle.

- (void)viewDidLoad
{
    [super viewDidLoad];
    _contentsView.dataSource = self;
    _objects = [NSMutableArray array];
    
    // Ready to PTP/IP.
    _ptpConnection = [[PtpConnection alloc] init];
    [_ptpConnection setLoglevel:PTPIP_LOGLEVEL_WARN];
    [_ptpConnection setEventListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
