//: ## Output Waveform Plot
//: If you open the Assitant editor and make sure it shows the
//: "Output Waveform Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the waveform in real time
import AudioKitPlaygrounds
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()
oscillator.start()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Output Waveform Plot")

        addSubview(AKPropertySlider(property: "Frequency",
                                    value: oscillator.baseFrequency,
                                    range: 0 ... 800,
                                    format: "%0.2f Hz"
        ) { frequency in
            oscillator.baseFrequency = frequency
        })

        addSubview(AKPropertySlider(property: "Carrier Multiplier",
                                    value: oscillator.carrierMultiplier,
                                    range: 0 ... 3
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        })

        addSubview(AKPropertySlider(property: "Modulating Multiplier",
                                    value: oscillator.modulatingMultiplier,
                                    range: 0 ... 3
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        })

        addSubview(AKPropertySlider(property: "Modulation Index",
                                    value: oscillator.modulationIndex,
                                    range: 0 ... 3
        ) { index in
            oscillator.modulationIndex = index
        })

        addSubview(AKPropertySlider(property: "Amplitude", value: oscillator.amplitude) { amplitude in
            oscillator.amplitude = amplitude
        })

        addSubview(AKOutputWaveformPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
