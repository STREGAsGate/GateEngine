/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (canImport(OpenALSoft) || canImport(LinuxSupport)) && !os(WASI)
#if canImport(OpenALSoft)
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif

internal class OASpacialMixerReference: SpacialAudioMixerReference {
    let context: OpenALContext

    init(_ contextReference: OAContextReference) {
        self.context = OpenALContext(spatialWithDevice: contextReference.device)
        context.resume()
        volume = 1
    }

    var volume: Float {
        get {
            return context.gain
        }
        set {
            context.gain = newValue
        }
    }

    var minimumAttenuationDistance: Float {
        get {
            return sourceWrappers.first(where: { $0.sourceReference != nil })?.sourceReference?
                .source.referenceDistance ?? 0
        }
        set {
            for sourceReference in sourceReferences {
                sourceReference.source.referenceDistance = newValue
            }
        }
    }

    func createListenerReference() -> any SpatialAudioListenerBackend {
        return OAListenerReference(self)
    }

    private class SourceWrapper {
        weak var sourceReference: OASourceReference? = nil
    }
    private var sourceWrappers: [SourceWrapper] = []
    private func getSourceWrapper() -> SourceWrapper {
        if let existing = sourceWrappers.first(where: { $0.sourceReference == nil }) {
            return existing
        }
        let new = SourceWrapper()
        sourceWrappers.append(new)
        return new
    }
    private var sourceReferences: [OASourceReference] {
        sourceWrappers.compactMap({ $0.sourceReference })
    }

    ///Generates a brand new audio source. You must store the returned object yourself, it is not retained by the mixer.
    func createSourceReference() -> any SpatialAudioSourceReference {
        let sourceReference = OASourceReference(self)
        let wrapper = getSourceWrapper()
        wrapper.sourceReference = sourceReference
        return sourceReference
    }
}

#endif
