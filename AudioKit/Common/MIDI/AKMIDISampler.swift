//
//  AKMIDISampler.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation
import CoreAudio

/// MIDI receiving Sampler
///
/// Be sure to enableMIDI if you want to receive messages
///
open class AKMIDISampler: AKSampler {
    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "MIDI Sampler"

    /// Initialize the MIDI Sampler
    public override init() {
        super.init()
        enableMIDI()
    }

    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start AudioKit
    ///
    /// - Parameters:
    ///   - midiClient: A refernce to the MIDI client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = AKMIDI().client,
                         name: String = "MIDI Sampler") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                self.handle(event: event)
            }
        })
    }

    private func handle(event: AKMIDIEvent) {
        self.handleMIDI(data1: event.internalData[0],
                        data2: event.internalData[1],
                        data3: event.internalData[2])
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = data1 >> 4
        let channel = data1 & 0xF

        if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0 {

            play(noteNumber: MIDINoteNumber(data2),
                 velocity: MIDIVelocity(data3),
                 channel: MIDIChannel(channel))

        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {

            stop(noteNumber: MIDINoteNumber(data2), channel: MIDIChannel(channel))

        } else if Int(status) == AKMIDIStatus.controllerChange.rawValue {

            midiCC(data2, value: data3, channel: channel)

        }
    }

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                 velocity: MIDIVelocity,
                                 channel: MIDIChannel) {
        if velocity > 0 {
            play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }

    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - controller: MIDI CC number
    ///   - value: MIDI CC value
    ///   - channel: MIDI CC channel
    ///
    open func midiCC(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        samplerUnit.sendController(controller, withValue: value, onChannel: channel)
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note
    open override func play(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    /// Stop a note
    open override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        samplerUnit.stopNote(noteNumber, onChannel: channel)
    }

    /// Discard all virtual ports
    open func destroyEndpoint() {
        if midiIn != 0 {
            MIDIEndpointDispose(midiIn)
            midiIn = 0
        }
    }

}
