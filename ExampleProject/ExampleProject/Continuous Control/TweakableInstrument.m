//
//  TweakableInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"
#import "OCSAssignment.h"

@interface TweakableInstrument ()
{
    //OCSPropertyManager *myPropertyManager;
    
    //maintain reference to properties so they can be referenced from controlling game logic 
    OCSProperty *amplitude;
    OCSProperty *frequency;
    OCSProperty *modulation;
    OCSProperty *modIndex;
}
@end


@implementation TweakableInstrument
@synthesize amplitude;
@synthesize frequency;
@synthesize modulation;
@synthesize modIndex;
//@synthesize myPropertyManager;
- (id)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
    
        amplitude  = [[OCSProperty alloc] initWithValue:kTweakableAmplitudeInit  minValue:kTweakableAmplitudeMin  maxValue:kTweakableAmplitudeMax];
        frequency  = [[OCSProperty alloc] initWithValue:kTweakableFrequencyInit  minValue:kTweakableFrequencyMin  maxValue:kTweakableFrequencyMax];
        modulation = [[OCSProperty alloc] initWithValue:kTweakableModulationInit minValue:kTweakableModulationMin maxValue:kTweakableModulationMax];
        modIndex   = [[OCSProperty alloc] initWithValue:kTweakableModIndexInit   minValue:kTweakableModIndexMin   maxValue:kTweakableModIndexMax];
        
        [amplitude  setControl:[OCSControl parameterWithString:@"Amplitude"]]; 
        [frequency  setControl:[OCSControl parameterWithString:@"Frequency"]]; 
        [modulation setControl:[OCSControl parameterWithString:@"Modulation"]]; 
        [modIndex   setControl:[OCSControl parameterWithString:@"ModIndex"]]; 
        
        [self addProperty:amplitude];
        [self addProperty:frequency];
        [self addProperty:modulation];
        [self addProperty:modIndex];
        
        //[myPropertyManager = [[OCSPropertyManager alloc] init];
        //[myPropertyManager addProperty:amplitude  forControllerNumber:12];
        //[myPropertyManager addProperty:modulation forControllerNumber:13];
        //[myPropertyManager addProperty:modIndex   forControllerNumber:14];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithAmplitude:[amplitude control] 
                                                    baseFrequency:[frequency control] 
                                                carrierMultiplier:ocsp(1) 
                                             modulatingMultiplier:[modulation control] 
                                                  modulationIndex:[modIndex control] 
                                                           fTable:sineTable];
        [self addOpcode:fmOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[fmOscillator output]];
        [self addOpcode:audio];
        
        /*
        // Test to show amplitude slider moving also
        [self addString:[NSString stringWithFormat:
         @"%@ = %@ + 0.001\n", amplitude, amplitude]];
         */
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    NSLog(@"Playing note at frequency = %0.2f", freq);
    [self playNoteForDuration:dur];
}


@end
