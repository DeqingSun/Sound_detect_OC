//
//  ViewController.m
//  Sound_detect_OC
//
//  Created by Sun Deqing on 6/13/14.
//  Copyright (c) 2014 Deqing Sun. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()
            

@end

@implementation ViewController



#define kOutputBus 0
#define kInputBus 1
AudioComponentInstance audioUnit;
AudioStreamBasicDescription audioFormat;


#pragma mark -RIO Render Callback
static OSStatus	recordingCallback(
                            void						*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp 		*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList 			*ioData)
{
  //  HiJackMgr *THIS = (HiJackMgr *)inRefCon;
    OSStatus err = AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    NSLog(@"asasadss");
    return err;
}






- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //setup_IO();
    NSError *sessionError;
    
    //7.0第一次运行会提示，是否允许使用麦克风
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    //AVAudioSessionCategoryPlayAndRecord用于录音和播放
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    
    [session requestRecordPermission:^(BOOL granted) {
        if(!granted)
        {
            NSLog(@"PERM NO");
        }
        
        else
        {
            NSLog(@"PERM YES");
        }
    }];
    
    BOOL success = [session setCategory: AVAudioSessionCategoryPlayAndRecord error: &sessionError];
    if (!success) { NSLog(@"setCategory ERR"); }
    
    NSTimeInterval bufferDuration = 0.005;
    success = [session
               setPreferredIOBufferDuration: bufferDuration
               error: &sessionError];
    if (!success) { NSLog(@"setPreferredIOBufferDuration ERR"); }
    
    success = [session setPreferredSampleRate: 44100
               error: &sessionError];
    if (!success) { NSLog(@"setPreferredSampleRate ERR"); }
    
    
    [session setActive: true error: &sessionError];
    
    
    
    
    
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
/*    // Disable playback IO
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));*/
    
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = 44100.00;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagsNativeFloatPacked |kAudioFormatFlagIsNonInterleaved;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 32;
    audioFormat.mBytesPerPacket     = 4;
    audioFormat.mBytesPerFrame      = 4;
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  0,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    status = AudioUnitInitialize(audioUnit);
    status = AudioOutputUnitStart(audioUnit);//!!!!!!!!!!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     OSStatus status;
     
     //AudioSessionInitialize(NULL, NULL, NULL, (__bridge void *)(self));
     
     // Describe audio component
     AudioComponentDescription desc;
     desc.componentType = kAudioUnitType_Output;
     desc.componentSubType = kAudioUnitSubType_RemoteIO;
     desc.componentFlags = 0;
     desc.componentFlagsMask = 0;
     desc.componentManufacturer = kAudioUnitManufacturer_Apple;
     
     // Get component
     AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
     
     // Get audio units
     status = AudioComponentInstanceNew(inputComponent, &audioUnit);
     NSLog(@"AudioComponentInstanceNew : %d", (int)status);
     
     UInt32 flag = 1;
     // Enable IO for recording
     status = AudioUnitSetProperty(audioUnit,
     kAudioOutputUnitProperty_EnableIO,
     kAudioUnitScope_Input,
     kInputBus,
     &flag,
     sizeof(flag));
     NSLog(@"AudioUnitSetProperty : %d", (int)status);
     
     
     //!!!!!!
     status = AudioUnitSetProperty(audioUnit,
     kAudioOutputUnitProperty_EnableIO,
     kAudioUnitScope_Output,
     kOutputBus,
     &flag,
     sizeof(flag));
     
     
     
     // Describe format
     audioFormat.mSampleRate			= 44100.00;
     audioFormat.mFormatID			= kAudioFormatLinearPCM;
     audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
     audioFormat.mFramesPerPacket	= 1;
     audioFormat.mChannelsPerFrame	= 1;
     audioFormat.mBitsPerChannel		= 16;
     audioFormat.mBytesPerPacket		= 2;
     audioFormat.mBytesPerFrame		= 2;
     
     //Apply format
     status = AudioUnitSetProperty(audioUnit,
     kAudioUnitProperty_StreamFormat,
     kAudioUnitScope_Output,
     kInputBus,
     &audioFormat,
     sizeof(audioFormat));
     NSLog(@"AudioUnitSetProperty : %d", (int)status);
     //!!!!!!!!
     status = AudioUnitSetProperty(audioUnit,
     kAudioUnitProperty_StreamFormat,
     kAudioUnitScope_Input,
     kOutputBus,
     &audioFormat,
     sizeof(audioFormat));
     
     
     
     
     // Set up the playback  callback
     AURenderCallbackStruct callbackStruct;
     callbackStruct.inputProc = recordingCallback;
     //set the reference to "self" this becomes *inRefCon in the playback callback
     callbackStruct.inputProcRefCon = (__bridge void *)(self);
     
     status = AudioUnitSetProperty(audioUnit,
     kAudioOutputUnitProperty_SetInputCallback,
     kAudioUnitScope_Global,
     kInputBus,
     &callbackStruct,
     sizeof(callbackStruct));
     
     NSLog(@"AudioUnitSetProperty : %d", (int)status);
     
     
     // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
     flag = 0;
     status = AudioUnitSetProperty(audioUnit,
     kAudioUnitProperty_ShouldAllocateBuffer,
     kAudioUnitScope_Output,
     kInputBus,
     &flag,
     sizeof(flag));
     
     
     
     // Initialise
     status = AudioUnitInitialize(audioUnit);
     NSLog(@"AudioUnitInitialize : %d", (int)status);
     //notice i do nothing with status, i should error check.
     
     */

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_press:(UIButton *)sender {
    NSLog(@"BT PRESSSED");
    
    
    

    
}


- (void)setupAudioSession
{
 /*   try {
        // Configure the audio session
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        
        // we are going to play and record so we pick that category
        NSError *error = nil;
        [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's audio category");
        
        // set the buffer duration to 5 ms
        NSTimeInterval bufferDuration = .005;
        [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's I/O buffer duration");
        
        // set the session's sample rate
        [sessionInstance setPreferredSampleRate:44100 error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's preferred sample rate");
        
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];
        
        // we don't do anything special in the route change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:sessionInstance];
        
        // if media services are reset, we need to rebuild our audio chain
        [[NSNotificationCenter defaultCenter]	addObserver:	self
                                                 selector:	@selector(handleMediaServerReset:)
                                                     name:	AVAudioSessionMediaServicesWereResetNotification
                                                   object:	sessionInstance];
        
        // activate the audio session
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session active");
    }
    
    catch (CAXException &e) {
        NSLog(@"Error returned from setupAudioSession: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        NSLog(@"Unknown error returned from setupAudioSession");
    }*/
    
    return;
}


- (void)setupIOUnit
{
/*    try {
        // Create a new instance of AURemoteIO
        
        AudioComponentDescription desc;
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;
        
        AudioComponent comp = AudioComponentFindNext(NULL, &desc);
        XThrowIfError(AudioComponentInstanceNew(comp, &_rioUnit), "couldn't create a new instance of AURemoteIO");
        
        //  Enable input and output on AURemoteIO
        //  Input is enabled on the input scope of the input element
        //  Output is enabled on the output scope of the output element
        
        UInt32 one = 1;
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "could not enable input on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one)), "could not enable output on AURemoteIO");
        
        // Explicitly set the input and output client formats
        // sample rate = 44100, num channels = 1, format = 32 bit floating point
        
        CAStreamBasicDescription ioFormat = CAStreamBasicDescription(44100, 1, CAStreamBasicDescription::kPCMFormatFloat32, false);
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &ioFormat, sizeof(ioFormat)), "couldn't set the input client format on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &ioFormat, sizeof(ioFormat)), "couldn't set the output client format on AURemoteIO");
        
        // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
        // of samples it will be asked to produce on any single given call to AudioUnitRender
        UInt32 maxFramesPerSlice = 4096;
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32)), "couldn't set max frames per slice on AURemoteIO");
        
        // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
        UInt32 propSize = sizeof(UInt32);
        XThrowIfError(AudioUnitGetProperty(_rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize), "couldn't get max frames per slice on AURemoteIO");
        
        _bufferManager = new BufferManager(maxFramesPerSlice);
        _dcRejectionFilter = new DCRejectionFilter;
        
        // We need references to certain data in the render callback
        // This simple struct is used to hold that information
        
        cd.rioUnit = _rioUnit;
        cd.bufferManager = _bufferManager;
        cd.dcRejectionFilter = _dcRejectionFilter;
        cd.muteAudio = &_muteAudio;
        cd.audioChainIsBeingReconstructed = &_audioChainIsBeingReconstructed;
        
        // Set the render callback on AURemoteIO
        AURenderCallbackStruct renderCallback;
        renderCallback.inputProc = performRender;
        renderCallback.inputProcRefCon = NULL;
        XThrowIfError(AudioUnitSetProperty(_rioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, sizeof(renderCallback)), "couldn't set render callback on AURemoteIO");
        
        // Initialize the AURemoteIO instance
        XThrowIfError(AudioUnitInitialize(_rioUnit), "couldn't initialize AURemoteIO instance");
    }
    
    catch (CAXException &e) {
        NSLog(@"Error returned from setupIOUnit: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        NSLog(@"Unknown error returned from setupIOUnit");
    }
    */
    return;
}

@end
