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
@property (nonatomic) NSString* deviceID;

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
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
    
    
    //initialize db
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *docsDir;
    NSArray *dirPaths;
    sqlite3_stmt    *statement;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"deviceTracker.db"]];
    
    //Connect to database
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
        {
            char *errMsg;
            //set schema if DEVICES table is not availabe
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS DEVICES (ID INTEGER PRIMARY KEY AUTOINCREMENT, DEVICEID TEXT, NAME TEXT, MADE TEXT)";
            
            //error message in case of database failure
            if (sqlite3_exec(_deviceTrackerDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _lblStatus.text = @"Failed to create table";
            }
            
            sqlite3_close(_deviceTrackerDB);
            
        } else {
            _lblStatus.text = @"Failed to open/create database";
        }
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation


- (IBAction)scanPressed:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            [_btnScan setTitle:@"Stop" forState:UIControlStateNormal];
            [_lblStatus setText:@"Scanning for QR Code..."];
        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        [_btnScan setTitle:@"Scan" forState:UIControlStateNormal];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
}

- (IBAction)verifyPressed:(id)sender {
    
    //_lblOutput.text = _deviceID;
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT deviceid, name, made FROM devices WHERE deviceid=\"%@\"",
                              _deviceID];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_deviceTrackerDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *nameField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 1)];
                
                NSString *madeField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                
                NSString* nameAndMade;
                nameAndMade = [nameAndMade stringByAppendingString:nameField];
                nameAndMade = [nameAndMade stringByAppendingString:madeField];
                _lblOutput.text = nameAndMade;
                
            } else {
                _lblOutput.text = @"Device not found";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_deviceTrackerDB);
    }
}

- (IBAction)insertPressed:(id)sender {
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        
        //1
        NSString *insertSQL1 = [NSString stringWithFormat:
                                @"INSERT INTO DEVICES (DEVICEID, NAME, MADE) VALUES (\"%@\", \"%@\", \"%@\")",
                                @"PNI-QA-MTD-001", @"GALAXY S5", @"SAMSUNG"];
        const char *insert_stmt1 = [insertSQL1 UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt1, -1, &statement, NULL);
        
        //#2
        NSString *insertSQL2 = [NSString stringWithFormat:
                                @"INSERT INTO DEVICES (DEVICEID, NAME, MADE) VALUES (\"%@\", \"%@\", \"%@\")",
                                @"PNI-QA-MTD-003", @"GALAXY S6", @"SAMSUNG"];
        const char *insert_stmt2 = [insertSQL2 UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt2, -1, &statement, NULL);
        
        //#3
        NSString *insertSQL3 = [NSString stringWithFormat:
                                @"INSERT INTO DEVICES (DEVICEID, NAME, MADE) VALUES (\"%@\", \"%@\", \"%@\")",
                                @"PNI-QA-MTD-005", @"GALAXY S7", @"SAMSUNG"];
        const char *insert_stmt3 = [insertSQL3 UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt3, -1, &statement, NULL);
        
        //#4
        NSString *insertSQL4 = [NSString stringWithFormat:
                                @"INSERT INTO DEVICES (DEVICEID, NAME, MADE) VALUES (\"%@\", \"%@\", \"%@\")",
                                @"PNI-QA-MTD-007", @"GALAXY S8", @"SAMSUNG"];
        const char *insert_stmt4 = [insertSQL4 UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt4, -1, &statement, NULL);
        
        //#5
        NSString *insertSQL5 = [NSString stringWithFormat:
                                @"INSERT INTO DEVICES (DEVICEID, NAME, MADE) VALUES (\"%@\", \"%@\", \"%@\")",
                                @"PNI-QA-MTD-009", @"GALAXY S9", @"SAMSUNG"];
        const char *insert_stmt5 = [insertSQL5 UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt5, -1, &statement, NULL);
        
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            _lblOutput.text = @"Data added";
        } else {
            _lblOutput.text = @"Failed to add data";
        }
        sqlite3_finalize(statement);
        sqlite3_close(_deviceTrackerDB);
    }
}

- (IBAction)statusPressed:(id)sender {
    _lblStatus.text = @"test status pressed";
}



#pragma mark - Private method implementation

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
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_btnScan performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            
            _isReading = NO;
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
                _deviceID = _lblStatus.text;
            }
        }
    }
    
}



@end
