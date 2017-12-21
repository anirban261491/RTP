//
//  EncoderDemoViewController.m
//  Encoder Demo
//
//  Created by Geraint Davies on 11/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "EncoderDemoViewController.h"
#import "CameraServer.h"

@implementation EncoderDemoViewController

@synthesize cameraView;
@synthesize serverAddress;

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [self startPreview];
    [self loadWebViewWithURL:[NSURL URLWithString:@"https://www.google.com"]];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:toInterfaceOrientation];
}

- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:UIInterfaceOrientationPortrait];
    
    [self.cameraView.layer addSublayer:preview];
    
    self.serverAddress.text = [[CameraServer server] getURL];
}

-(void)loadWebViewWithURL:(NSURL*)url
{
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
    [_webView loadRequest:nsrequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
