//
//  DrawbarsOscillator.hpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-02.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#include "FunctionTable.hpp"
#include "WaveStack.hpp"

namespace AudioKitCore
{

    // DrawbarsOscillator is WaveStack-based oscillator which implements multiple simultaneous
    // waveform-readout phases, whose frequencies are related as a harmonic series, as in a
    // traditional "drawbar" organ.

    struct DrawbarsOscillator
    {
        // current output sample rate
        double sampleRateHz;

        // pointer to shared WaveStack
        WaveStack *pWaveStack;

        // per-phase variables
        static constexpr int numPhases = 16;

        // WaveStack octave used by this phase
        int octave[numPhases];

        // Fraction of the way through waveform
        float phase[numPhases];

        // normalized frequency: cycles per sample
        float phaseDelta[numPhases];

        // relative level of this phase (fraction)
        float level[numPhases];

        // performance variables

        // phaseDelta multiplier for pitchbend, vibrato
        float phaseDeltaMul;

        void init(double sampleRate, WaveStack* pStack);
        void setDrawbars(float levels[]);
        void setFrequency(float frequency);

        float getSample();
        void getSamples(float *pLeft, float *pRight, float gain);
    };

}
