//
//  ViewController.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) NSMutableString* deviceID;
@property (nonatomic, strong) NSMutableString* userID;
@property (nonatomic, strong) dbManager *dbManager;

#define returnAlertView 1
#define borrowAlertView 2
#define scanUserAlertView 3
#define scanDeviceAlertView 4
#define deviceNotFoundAlertView 5

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

    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
    
    
    //initialize db
    self.dbManager = [[dbManager alloc] init];

    // Initilize table when program starts
    if (![self.dbManager initialize])
        _lblStatus.text = @"Failed to create table";
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self reset];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation


- (IBAction)scanPressed:(id)sender {
    _lblStatus.text = @"test scan pressed";
}

- (IBAction)verifyPressed:(id)sender {
    
    NSArray* deviceStatus = [self.dbManager getDeviceStatus:_deviceID];
    
    if (deviceStatus) {
        
        NSString* deviceModel = (NSString*)deviceStatus[0];
        NSString* deviceMade = (NSString*)deviceStatus[1];
        NSString* deviceOS = (NSString*)deviceStatus[2];
        NSString* deviceScreen = (NSString*)deviceStatus[3];
        NSString* userName = (NSString*)deviceStatus[4];
        NSString* checkOutTime = (NSString*)deviceStatus[5];
        
        
            _lblOutput.text = [NSString stringWithFormat:@"%@ , %@" , deviceMade, deviceModel];
            _lblStatus.text = userName;
        
        
            UIImage *image = [UIImage imageNamed: [NSString stringWithFormat: @"%@.jpg", deviceModel]];
            _imageOutput.contentMode = UIViewContentModeScaleAspectFit;
            _imageOutput.clipsToBounds = YES;
            [_imageOutput setImage:image];
    }
    
}


- (IBAction)insertPressed:(id)sender {
    if ([self.dbManager insertData])
        _lblOutput.text = @"Data added";
    else
        _lblOutput.text = @"Failed to add data";
   }

- (IBAction)statusPressed:(id)sender {
    _lblStatus.text = @"test status pressed";
}



#pragma mark - Private method implementation

-(void)reset{
    
    _userID = nil;
    _deviceID = nil;
    
    //_lblOutput.text = @"";
    
    _lblOutput.text = @"";
    if (_lblOutput.text.length < 1)
        _lblOutput.text = @"Please scan a device you would like to borrow!";
        
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

-(void)scannedDevice:(NSString*) deviceID{
    NSLog(@"Device : %@ scanned.", deviceID);
    
    //Check if device could be found in DB
    if ([self.dbManager isDeviceFoundInDB:deviceID]) {
        
        _deviceID =[deviceID mutableCopy];
        
        _lblOutput.text = [NSString stringWithFormat:@"%@", _deviceID];
        
        NSArray* deviceStatus = [self.dbManager getDeviceStatus:deviceID];
        
        if ([Device isDeviceAvailable:deviceStatus]) {
            
            NSLog(@"Device : %@ available", deviceID);
            
            if (_userID) {
                UIAlertView * borrowAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Borrow Devices?"]
                                                                       message:[NSString stringWithFormat:@"Does %@ want to borrow %@", _userID, _deviceID]
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles: nil];
                
                //add image to pop up for iOS 7+
                //set image view size
                UIImageView *deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 10, 70, 40)];
                //load image
                UIImage *deviceImage = [UIImage imageNamed:@"iPhone 6 (Space Gray).jpg"];
                //set image to imageView
                [deviceImageView setImage:deviceImage];
                //insert image view to the pop up
                [borrowAlert setValue:deviceImageView forKey:@"accessoryView"];
                
                [borrowAlert addButtonWithTitle:@"Borrow"];
                [borrowAlert setTag:borrowAlertView];
                [borrowAlert show];
            }else{
                UIAlertView * scanUserAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Device : %@ ",deviceID]
                                                                         message:@"Please scan your ID QR to continue!"
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles: nil];
                [scanUserAlert setTag:scanUserAlertView];
                [scanUserAlert show];
            }
        }else{
            UIAlertView * returnAlert =[[UIAlertView alloc ] initWithTitle:@"Return Device?"
                                                                   message:[NSString stringWithFormat:@"Do you want to return %@",deviceID]
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles: nil];
            
            //add image to pop up for iOS 7+
            //set image view size
            UIImageView *deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 10, 70, 40)];
            //load image
            UIImage *deviceImage = [UIImage imageNamed:@"iPhone 6 (Space Gray).jpg"];
            //set image to imageView
            [deviceImageView setImage:deviceImage];
            //insert image view to the pop up
            [returnAlert setValue:deviceImageView forKey:@"accessoryView"];
            
            //add options and show Alert
            [returnAlert addButtonWithTitle:@"Return"];
            [returnAlert setTag:returnAlertView];
            [returnAlert show];

// 高大上
//            PopUpViewController *popViewController = [[PopUpViewController alloc] initWithNibName:@"PopUpViewController" bundle:nil];
//            [popViewController setTitle:@"This is a popup view"];
//            [popViewController showInView:self.view
//                                withImage:[UIImage imageNamed:@"iPhone 5 (Black).jpg"]
//                              withMessage:@"Your Message" animated:YES];
            
        }
        
    }else{
        NSLog(@"Device : %@ not found in DB", deviceID);
        
        UIAlertView * deviceNotFoundAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Device : %@ ",deviceID]
                                                                 message:@"Device not Found in DB, please try again!"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
        [deviceNotFoundAlert setTag:deviceNotFoundAlertView];
        [deviceNotFoundAlert show];
    }
}

-(void)scannedUser:(NSString*) userID{
    NSLog(@"User : %@ scanned.", userID);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 40, 40)];
    [imageView setImage:[UIImage imageNamed:@"QR_Icon.png"]];

    
    //TODO: Check if ID is valid
    _userID = [[userID mutableCopy] componentsSeparatedByString:@"-"][3];
    
    if(_deviceID){
        UIAlertView * borrowAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"Borrow Devices?"]
                                                               message:[NSString stringWithFormat:@"Does %@ want to borrow %@", _userID, _deviceID]
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles: nil];
        [borrowAlert addButtonWithTitle:@"Borrow"];
        [borrowAlert addSubview:imageView];
        [borrowAlert setTag:borrowAlertView];
        [borrowAlert show];
    }
    else{
        UIAlertView * scanDeviceAlert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"User : %@ ",_userID]
                                                                 message:@"Please scan your Device to continue!"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
        [scanDeviceAlert setTag:scanDeviceAlertView];
        [scanDeviceAlert show];

    }
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
            self.lblStatus.text = @"Please scan your ID to continue checkout!";
            [self startReading];
        }
        else if(alertView.tag == scanDeviceAlertView){
            NSLog(@"User is going to scan device next");
            self.lblStatus.text = @"Please scan the device you would like to borrow!";
            [self startReading];
        }
        else if(alertView.tag == deviceNotFoundAlertView){
            NSLog(@"User is going to start again");
            
            [self reset];
        }
    }
    else if(buttonIndex == 1)
    {
        if(alertView.tag == returnAlertView){
            NSLog(@"User would like to return");
            
            if ([self.dbManager returnDevice:self.deviceID])
                self.lblStatus.text = @"Checkin completed!";
            else
                self.lblStatus.text = @"Device cannot be returned at this moment, please try again";
            
            [self reset];
        }
        else if(alertView.tag == borrowAlertView){
            NSLog(@"User would like to borrow");
            
            if ([self.dbManager borrowDevice:self.deviceID asUserName:self.userID])
                self.lblStatus.text = @"Checkout completed!";
            else
                self.lblStatus.text = @"Device cannot be checked out at this moment, please try again";
            
            [self reset];
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
                
                if ([[metadataObj stringValue] containsString:@"PNI"]) {
                    
                    _isReading= NO;
                    
                    [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
                    
                    if([[metadataObj stringValue] containsString:@"MTD"]){
                        
                        NSLog(@"MTD Scanned");
                        
                        [self scannedDevice:[metadataObj stringValue]];
                        
                    }else if([[metadataObj stringValue] containsString:@"USR"]){
                        
                        NSLog(@"USR Scanned");
                        
                        [self scannedUser:[metadataObj stringValue]];
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
}

- (BOOL)shouldAutorotate { return NO; }

@end
