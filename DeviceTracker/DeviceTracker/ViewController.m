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
@property (nonatomic) BOOL isReturned;
@property (nonatomic, strong) NSMutableString* deviceID;

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
    
    _isReading = NO;
    _isReturned = YES;
    
    _deviceID = [[NSMutableString alloc] initWithString:@""];
    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
    
    
    //initialize db
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *docsDir;
    NSArray *dirPaths;
    
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
            "CREATE TABLE IF NOT EXISTS DEVICES (ID INTEGER PRIMARY KEY AUTOINCREMENT, DEVICEID TEXT, NAME TEXT, MADE TEXT, RETURNED INTEGER)";
            
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startReading];
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
    
    BOOL validDevicesScanned = NO;
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT deviceid, name, made, returned FROM devices WHERE deviceid=\"%@\"",
                              //@"SELECT deviceid, name, made FROM devices"];
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
                
                _isReturned = (BOOL)sqlite3_column_int(statement, 3);
                
                //allocate memory for object
                NSString* nameAndMade = [[NSString alloc] init];
                nameAndMade = [nameAndMade stringByAppendingString:nameField];
                nameAndMade = [nameAndMade stringByAppendingString:madeField];
                _lblOutput.text = [NSString stringWithFormat:
                                   @"%@",nameAndMade];
                validDevicesScanned = YES;
                
            } else {
                _lblOutput.text = @"Device not found";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_deviceTrackerDB);
    }
    
    if (validDevicesScanned) {
        if(_isReturned)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Checkout Device" message:@"Are you sure you would like to check out this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
            {
                NSString *querySQL = [NSString stringWithFormat:
                                      @"UPDATE devices SET returned = 0 WHERE deviceid=\"%@\"",
                                      _deviceID];
                
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(_deviceTrackerDB,
                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        _lblOutput.text = @"Device checkout!";
                    } else {
                        _lblOutput.text = @"Device cant be checkout";
                    }
                    sqlite3_finalize(statement);
                }
                sqlite3_close(_deviceTrackerDB);
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Return Device" message:@"Are you sure you would like to return this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
            {
                NSString *querySQL = [NSString stringWithFormat:
                                      @"UPDATE devices SET returned = 1 WHERE deviceid=\"%@\"",
                                      _deviceID];
                
                const char *query_stmt = [querySQL UTF8String];
                
                if (sqlite3_prepare_v2(_deviceTrackerDB,
                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        _lblOutput.text = @"Device returned";
                    } else {
                        _lblOutput.text = @"Device cant be returned";
                    }
                    sqlite3_finalize(statement);
                }
                sqlite3_close(_deviceTrackerDB);
            }
        }
        _lblStatus.text = @"";
        [_deviceID setString:@""];
    }
    
}

- (IBAction)insertPressed:(id)sender {
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        
        //insert into tablename ( col1, col2, col3) values
        // (val1, val2, val3),
        // (val1, val2, val3),
        // (val1, val2, val3);
        NSString *combinedSQL = [NSString stringWithFormat:
                                 @"INSERT INTO DEVICES ( DEVICEID , NAME , MADE, RETURNED) VALUES "
                                 "(\"PNI-QA-MTD-001\", \"GALAXY S1\", \"Samsung1\" , 1),"
                                 "(\"PNI-QA-MTD-003\", \"GALAXY S3\", \"Samsung3\" , 1),"
                                 "(\"PNI-QA-MTD-005\", \"GALAXY S5\", \"Samsung5\" , 1),"
                                 "(\"PNI-QA-MTD-007\", \"GALAXY S7\", \"Samsung7\" , 1)"
                                 ";"];
        
        const char *insert_stmt1 = [combinedSQL UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt1, -1, &statement, NULL);
        
        
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
    [_videoPreviewLayer setFrame:self.viewPreview.bounds];
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
            
            //[self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[_btnScan performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            
            //make a copy of the device id when QR reading is successful
            [_deviceID setString: _lblStatus.text];
        }
    }
    
}

- (BOOL)shouldAutorotate { return NO; }

@end
