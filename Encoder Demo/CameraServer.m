//
//  CameraServer.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraServer.h"
#import "AVEncoder.h"
#import "RTSPServer.h"
#import <ReplayKit/ReplayKit.h>

static CameraServer* theServer;

@interface CameraServer  () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _session;
    AVCaptureVideoPreviewLayer* _preview;
    AVCaptureVideoDataOutput* _output;
    dispatch_queue_t _captureQueue;
    
    AVEncoder* _encoder;
    
    RTSPServer* _rtsp;
    int screenWidth, screenHeight;
    int FR;
    RPScreenRecorder *recorder;
}
@end


@implementation CameraServer

+ (void) initialize
{
    // test recommended to avoid duplicate init via subclass
    if (self == [CameraServer class])
    {
        theServer = [[CameraServer alloc] init];
    }
}

+ (CameraServer*) server
{
    return theServer;
}

- (void) startup
{
    if (_session == nil)
    {
//        NSLog(@"Starting up server");
//
//        // create capture device with video input
//        _session = [[AVCaptureSession alloc] init];
//        AVCaptureDevice* dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:dev error:nil];
//        [_session addInput:input];
//
//        // create an output for YUV output with self as delegate
//        _captureQueue = dispatch_queue_create("uk.co.gdcl.avencoder.capture", DISPATCH_QUEUE_SERIAL);
//        _output = [[AVCaptureVideoDataOutput alloc] init];
//        [_output setSampleBufferDelegate:self queue:_captureQueue];
////        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
////                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
////                                        nil];
////        _output.videoSettings = setcapSettings;
//        [_output setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey,nil]];
//        [_session addOutput:_output];
        
        // create an encoder with screen height and screen width
        
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
        screenHeight = [[UIScreen mainScreen] bounds].size.height;
        _encoder = [AVEncoder encoderForHeight:screenHeight andWidth:screenWidth];
        [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
            if (_rtsp != nil)
            {
                _rtsp.bitrate = _encoder.bitspersecond;
                [_rtsp onVideoData:data time:pts];
            }
            return 0;
        } onParams:^int(NSData *data) {
            _rtsp = [RTSPServer setupListener:data];
            return 0;
        }];
        
        // start capture and a preview layer
//        [_session startRunning];
//
//
//        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
//        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self initializeScreenRecorder];
        
        [recorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
            if(bufferType==1)
            {
                FR=(FR+1)%2;
                if(FR)
                   [_encoder sendForEncoding:sampleBuffer];
            }
        } completionHandler:nil];
    }
}




- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    [_encoder sendForEncoding:sampleBuffer];
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;
    }
    if (_rtsp)
    {
        [_rtsp shutdownServer];
    }
    if (_encoder)
    {
        [ _encoder shutdown];
    }
}

- (NSString*) getURL
{
    NSString* ipaddr = [RTSPServer getIPAddress];
    NSString* url = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
    return url;
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    return _preview;
}

-(void)initializeScreenRecorder
{
    FR=0;
    recorder=[RPScreenRecorder sharedRecorder];
}


@end
