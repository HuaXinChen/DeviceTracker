//
//  ViewController.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2015 PNI. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) NSMutableString* deviceID;
@property (nonatomic, strong) NSMutableString* deviceObjectID;
@property (nonatomic, strong) NSMutableString* userName;
@property (nonatomic, strong) NSMutableString* userObjectID;

#define returnAlertView 1
#define borrowAlertView 2
#define scanUserAlertView 3
#define scanDeviceAlertView 4
#define deviceNotFoundAlertView 5
#define reachMaxNumberOfDeviceBorrowed 6

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    _deviceID = [[NSMutableString alloc] init];
    _deviceObjectID =[[NSMutableString alloc] init];
    _userName = [[NSMutableString alloc] init];
    _deviceObjectID = [[NSMutableString alloc] init];

    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self reset];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self stopReading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation


#pragma mark - Private method implementation

-(void)reset{
    
    _userName = nil;
    _userObjectID = nil;
    _deviceID = nil;
    _deviceObjectID = nil;
    
    if (_lblStatus.text.length < 1)
        _lblStatus.text = @"Scan DEVICE or USER QR";
        
    [self startReading];
}

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    //dispatch_queue_t dispatchQueue;
    //dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.viewPreview.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    _isReading = YES;
    
    return YES;
}

-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
    
    _isReading = NO;
}

-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}

-(void)scannedDevice:(NSString*) deviceObjectID{
    NSLog(@"Device : %@ scanned.", deviceObjectID);
    
    //set deviceObjectID to global variable
    _deviceObjectID= deviceObjectID;
    
    PFQuery *deviceQuery = [PFQuery queryWithClassName:@"Devices"];
    
    //get device object from cloud
    [deviceQuery getObjectInBackgroundWithId:_deviceObjectID block:^(PFObject *device, NSError *error) {
        NSLog(@"%@", device);
        
        //extract device id, user and model from device object
        _deviceID = device[@"deviceId"];
        NSString *deviceUser = device[@"user"];
        NSString *deviceModel = device[@"model"];
        
        //device is not in DB, display error message
        if(_deviceID == NULL){
            NSLog(@"Device : %@ not found in DB", _deviceID);
            
            UIAlertView * deviceNotFoundAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Device: %@ ",_deviceID]
                                                                           message:@"Device not found"
                                                                          delegate:self
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles: nil];
            [deviceNotFoundAlert setTag:deviceNotFoundAlertView];
            [deviceNotFoundAlert show];
        }
        
        //device is found in DB, process checkin OR checkout
        else{
            //device is availabe
            if ([deviceUser isEqual: @""]){
                NSLog(@"Device : %@ available", _deviceID);
                
                //if user QR is scanned, trigger checkout
                if (_userName) {
                    UIAlertView * borrowAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"User: %@", _userName]
                                                                           message:[NSString stringWithFormat:@"Borrow %@?", deviceModel]
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles: nil];
                    
                    //set image view size
                    UIImageView *deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 10, 70, 40)];
                    //load image
                    UIImage *deviceImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@.jpg", deviceModel]];
                    //set image to imageView keep the ratio
                    [deviceImageView setImage:deviceImage];
                    deviceImageView.contentMode = UIViewContentModeScaleAspectFit;
                    //insert image view to the pop up
                    [borrowAlert setValue:deviceImageView forKey:@"accessoryView"];
                    [borrowAlert addButtonWithTitle:@"Borrow"];
                    [borrowAlert setTag:borrowAlertView];
                    [borrowAlert show];
                }
                
                //if user QR is not scanned, show message
                else{
                    UIAlertView * scanUserAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Device: %@ ",_deviceID]
                                                                             message:@"Scan USER QR"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles: nil];
                    [scanUserAlert setTag:scanUserAlertView];
                    [scanUserAlert show];
                }
            }
            //device is not availabe, trigger checkin
            else{
                UIAlertView * returnAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Device: %@", _deviceID]
                                                                       message:[NSString stringWithFormat:@"Return %@?",deviceModel]
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles: nil];
                
                //set image view size
                UIImageView *deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 10, 70, 40)];
                //load image
                UIImage *deviceImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@.jpg", deviceModel]];
                //set image to imageView and keep the ratio
                [deviceImageView setImage:deviceImage];
                deviceImageView.contentMode = UIViewContentModeScaleAspectFit;
                
                //insert image view to the pop up
                [returnAlert setValue:deviceImageView forKey:@"accessoryView"];
                
                //add options and show Alert
                [returnAlert addButtonWithTitle:@"Return"];
                [returnAlert setTag:returnAlertView];
                [returnAlert show];
                
            }
        }
    }];
    //add spinner
}

-(void)scannedUser:(NSString*) userObjectID{
    NSLog(@"User : %@ scanned.", userObjectID);
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"Users"];
    
    //set the objectID to global value
    _userObjectID = userObjectID;
    
    //get user object from cloud
    [userQuery getObjectInBackgroundWithId:userObjectID block:^(PFObject *user, NSError *error) {
        NSLog(@"%@", user);
        //extract user name, and set it to global variable
        _userName = user[@"userName"];
        NSNumber *numberOfDeviceBorrowed = user[@"numberOfDeviceBorrowed"];
        
        //if the user has already borrowed 2 or more devices
        if ( [numberOfDeviceBorrowed intValue] >= 2) {
            UIAlertView * scanDeviceAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"User: %@ ",_userName]
                                                                       message:@"Cannot check out more than 2 devices!"
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles: nil];
            [scanDeviceAlert setTag:reachMaxNumberOfDeviceBorrowed];
            [scanDeviceAlert show];
        }
        
        //if device QR is already scanned, trigger checkout
        else if(_deviceObjectID){
            //get device object
            PFQuery *deviceQuery = [PFQuery queryWithClassName:@"Devices"];
            [deviceQuery getObjectInBackgroundWithId:_deviceObjectID block:^(PFObject *device, NSError *error) {
                NSLog(@"%@", device);
                
                //extract device id and model
                _deviceID = device[@"deviceId"];
                NSString *deviceModel = device[@"model"];
                
                //pop up for confirmation
                UIAlertView * borrowAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"User: %@", _userName]
                                                                       message:[NSString stringWithFormat:@"Borrow %@?", deviceModel]
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles: nil];
                
                //set image view size
                UIImageView *deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 10, 70, 40)];
                //load image
                UIImage *deviceImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@.jpg", deviceModel]];
                
                //set image to imageView keep the ratio
                [deviceImageView setImage:deviceImage];
                deviceImageView.contentMode = UIViewContentModeScaleAspectFit;
                //insert image view to the pop up
                [borrowAlert setValue:deviceImageView forKey:@"accessoryView"];
                [borrowAlert addButtonWithTitle:@"Borrow"];
                [borrowAlert setTag:borrowAlertView];
                [borrowAlert show];
            }];
        }
        
        //if Device QR is not scanned, display message
        else{
            UIAlertView * scanDeviceAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"User: %@ ",_userName]
                                                                       message:@"Scan DEVICE QR!"
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles: nil];
            [scanDeviceAlert setTag:scanDeviceAlertView];
            [scanDeviceAlert show];
        }

    }];
    
}

#pragma mark - UIAlertViewDelegate method implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Button Index =%ld",buttonIndex);
    if (buttonIndex == 0)
    {
        if(alertView.tag == returnAlertView){
            NSLog(@"User cancel on return");
            [self reset];
        }
        else if(alertView.tag == borrowAlertView){
            NSLog(@"User cancel on borrow");
            [self reset];
        }
        else if(alertView.tag == scanUserAlertView){
            NSLog(@"User is going to scan ID next");
            self.lblStatus.text = @"Scan USER QR!";
            [self startReading];
        }
        else if(alertView.tag == scanDeviceAlertView){
            NSLog(@"User is going to scan device next");
            self.lblStatus.text = @"Scan DEVICE QR!";
            [self startReading];
        }
        else if(alertView.tag == deviceNotFoundAlertView){
            NSLog(@"User is going to start again");
            [self reset];
        }
        else if(alertView.tag == reachMaxNumberOfDeviceBorrowed){
            NSLog(@"User has reached the max number of device to borrow");
            [self reset];
        }
    }
    else if(buttonIndex == 1)
    {
        PFQuery *deviceQuery = [PFQuery queryWithClassName:@"Devices"];
        if(alertView.tag == returnAlertView){
            NSLog(@"User would like to return");
            
            //update to cloud, clear the user cell for returned device
            [deviceQuery getObjectInBackgroundWithId:_deviceObjectID block:^(PFObject *device, NSError *error) {
                NSString *deviceUser = device[@"user"];
                NSString *deviceUserObjectId = device[@"userObjectId"];
                device[@"user"] = @"";
                device[@"userObjectId"] = @"";
                
                [device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"%@",device);
                        self.lblStatus.text = @"Checkin completed!";
                    } else {
                        NSLog(@"%@",error);
                        self.lblStatus.text = @"Device cannot be returned at this moment, please try again";
                    }
                }];
                
                //log the transaction
                PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
                transaction[@"deviceId"] = device[@"deviceId"];
                transaction[@"model"] = device[@"model"];
                transaction[@"user"] = deviceUser;
                transaction[@"userObjectId"] = deviceUserObjectId;
                transaction[@"action"] = @"return";
                [transaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
                
                //decrement borrowed counter for that user
                PFObject *user = [PFObject objectWithoutDataWithClassName:@"Users" objectId:deviceUserObjectId];
                [user incrementKey:@"numberOfDeviceBorrowed" byAmount:[NSNumber numberWithInt:-1]];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];

                
                [self reset];
            }];
        }
        
        else if(alertView.tag == borrowAlertView){
            NSLog(@"User would like to borrow");
            
            //update to cloud, update device user cell with borrower's username
            [deviceQuery getObjectInBackgroundWithId:_deviceObjectID block:^(PFObject *device, NSError *error) {
                device[@"user"] = _userName;
                device[@"userObjectId"] = _userObjectID;
                [device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                       NSLog(@"%@",device);
                       self.lblStatus.text = @"Checkout completed!";
                    } else {
                       NSLog(@"%@",error);
                       self.lblStatus.text = @"Device cannot be borrowed at this moment, please try again";
                    }
                }];
                
                //log the transaction
                PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
                transaction[@"deviceId"] = device[@"deviceId"];
                transaction[@"model"] = device[@"model"];
                transaction[@"user"] = _userName;
                transaction[@"action"] = @"borrow";
                [transaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];

                //increment borrowed counter for that user
                PFObject *user = [PFObject objectWithoutDataWithClassName:@"Users" objectId:_userObjectID];
                [user incrementKey:@"numberOfDeviceBorrowed" byAmount:[NSNumber numberWithInt:1]];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
                
                [self reset];
            }];
        }
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (_isReading) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects != nil && [metadataObjects count] > 0) {
            // Get the metadata object.
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                // If the found metadata is equal to the QR code metadata then update the status label's text,
                // stop reading and change the bar button item's title and the flag's value.
                // Everything is done on the main thread.
                
                if([[metadataObj stringValue] containsString:@"MTD"]){
                    _isReading= NO;
                    //[_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
                    
                    NSLog(@"MTD Scanned");
                    
                    [self scannedDevice: [[metadataObj stringValue] substringWithRange:NSMakeRange(3, 10)]];
                    
                }else if([[metadataObj stringValue] containsString:@"USR"]){
                    
                    _isReading= NO;
                    //[_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
                    
                    NSLog(@"USR Scanned");
                    
                    [self scannedUser:[[metadataObj stringValue] substringWithRange:NSMakeRange(3, 10)]];
                }
                
                [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
                
                // If the audio player is not nil, then play the sound effect.
                if (_audioPlayer) {
                    [_audioPlayer play];
                }
            }
        }
    }
}

- (BOOL)shouldAutorotate { return NO; }
@end
