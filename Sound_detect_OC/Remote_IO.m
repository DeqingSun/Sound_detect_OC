//
//  Remote_IO.m
//  Sound_detect_OC
//
//  Created by Sun Deqing on 6/13/14.
//  Copyright (c) 2014 Deqing Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kOutputBus 0
#define kInputBus 1
AudioComponentInstance audioUnit;
AudioStreamBasicDescription audioFormat;

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.
    
    AudioBufferList *bufferList; // <- Fill this up with buffers (you will want to malloc it, as it's a dynamic-length list)
    
    // Then:
    // Obtain recorded samples
    
    OSStatus status;
    NSLog(@"ssdsdfsdf");
    /* status = AudioUnitRender([audioUnit,
     ioActionFlags,
     inTimeStamp,
     inBusNumber,
     inNumberFrames,
     bufferList);*/
    // checkStatus(status);
    
    // Now, we have the samples we just read sitting in buffers in bufferList
    //  DoStuffWithTheRecordedAudio(bufferList);
    return noErr;
}



void setup_IO(){
    NSError *sessionError;
    
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if(!granted)
        {
            NSLog(@"PERM NO");
        }
        
        else
        {
            NSLog(@"PERM YES");
        }
    }];
    
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryRecord
                    error: &sessionError];
    if (!success) { NSLog(@"setCategory ERR"); }
    
    NSTimeInterval bufferDuration = 0.005;
    success = [[AVAudioSession sharedInstance]
               setPreferredIOBufferDuration: bufferDuration
               error: &sessionError];
    if (!success) { NSLog(@"setPreferredIOBufferDuration ERR"); }
    
    success = [[AVAudioSession sharedInstance]
               setPreferredSampleRate: 44100
               error: &sessionError];
    if (!success) { NSLog(@"setPreferredSampleRate ERR"); }
    
    
    [[AVAudioSession sharedInstance]
     setActive: true
     error: &sessionError];
    
    
    
    
    
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
    // Disable playback IO
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    
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
    callbackStruct.inputProcRefCon = NULL;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    status = AudioUnitInitialize(audioUnit);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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