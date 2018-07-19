//
//  StorageProperties.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/7/13.
//  Copyright © 2018 李灿晨. All rights reserved.
//
//  Abstract:
//  This file contains the storage properties of a single drawing, include stroke sample, stroke, stroke layer,
//  etc. The structs / classes are all serializable

import Foundation
import UIKit


enum StrokePhase: Int, Codable {
    case begin
    case changed
    case ended
    case cancelled
}


enum StrokeState: Int, Codable {
    case active
    case done
    case cancelled
}


/**
 * StrokeSample is a single that records a single point of the user's touch on the screen
 * it contains the location and the time stamp data of a single touch
 */
struct StrokeSample: Codable {
    
    // Must-have properties
    let timeStamp: TimeInterval
    let location: CGPoint
    
    init(timeStamp: TimeInterval, location: CGPoint) {
        self.timeStamp = timeStamp
        self.location = location
    }
    
    func within(center: CGPoint, radius: CGFloat) -> Bool {
        let xDistance = location.x - center.x
        let yDistance = location.y - center.y
        let distanceSquare = xDistance * xDistance + yDistance * yDistance
        return distanceSquare < radius * radius
    }
}

/**
 * Stroke represents a single stroke on a painting, it's consists of stroke samples, and provides the render
 * information about the stroke
 */
struct Stroke: Codable, Sequence {
    
    var samples: [StrokeSample] = []
    var state: StrokeState = .active
    var renderMechanism: RenderMechanism!
    
    init(renderMechanism: RenderMechanism) {
        self.renderMechanism = renderMechanism
    }
    
    mutating func add(sample: StrokeSample) {
        samples.append(sample)
    }
    
    func makeIterator() -> StrokeArcIterator {
        return StrokeArcIterator(stroke: self)
    }
    
}

struct StrokeArc {
    
    var sampleBefore: StrokeSample
    var sample: StrokeSample
    var sampleAfter: StrokeSample
    
    init(sampleBefore: StrokeSample, sample: StrokeSample, sampleAfter: StrokeSample) {
        self.sampleBefore = sampleBefore
        self.sample = sample
        self.sampleAfter = sampleAfter
    }
    
}


/**
 * Layer is the layer in the painting, each layer is separate physically
 */
struct Layer: Codable {
    var identifier: String = "new layer"
    var strokes: [Stroke] = []
    
    mutating func add(stroke: Stroke) {
        strokes.append(stroke)
    }
}

/**
 * SubStep contains the pointers (actually indices of layer and stroke) to the strokes with same color and
 * texture
 */
struct SubStep: Codable, Sequence {
    
    var renderDescription: String = "no render description"
    var relatedOperationLayer: [Int] = []
    var relatedOperationStroke: [Int] = []
    var renderMechanism: RenderMechanism
    
    mutating func add(layerIndex: Int, strokeIndex: Int) {
        relatedOperationLayer.append(layerIndex)
        relatedOperationStroke.append(strokeIndex)
    }
    
    mutating func remove(at index: Int) {
        relatedOperationLayer.remove(at: index)
        relatedOperationStroke.remove(at: index)
    }
    
    mutating func setRenderMechanism(with mechanism: RenderMechanism) {
        renderMechanism = mechanism
    }
    
    func makeIterator() -> SubStepContentIterator {
        return SubStepContentIterator(subStep: self)
    }
    
}

/**
 * Step is the collection of SubStep, it contains multiple sub steps, that means it may be related with multiple
 * color and texture of strokes
 */
struct Step: Codable {
    
    var description: String = "no description"
    var subSteps: [SubStep] = []
    
    mutating func add(subStep: SubStep) {
        subSteps.append(subStep)
    }
}



struct ArtworkGuide: Codable {
    
    var steps: [Step] = []
    
    mutating func add(step: Step) {
        steps.append(step)
    }
}


/**
 * Artwork is the top level of stroage, each Artwork correspond to a painting, an Artwork is consisted of
 * multiple stroke layers
 */
struct Artwork: Codable {
    
    var identifier: String = "new artwork"
    var layers: [Layer] = []
    var guide: ArtworkGuide? = nil
    
    mutating func add(layer: Layer) {
        layers.append(layer)
    }
}



// MARK: Supportive classes
class SubStepContentIterator: IteratorProtocol {
    
    private let subStep: SubStep
    private var nextIndex: Int = 0
    
    init(subStep: SubStep) {
        self.subStep = subStep
    }
    
    func next() -> (Int, Int)? {
        if nextIndex >= subStep.relatedOperationLayer.count {
            return nil
        }
        let result = (subStep.relatedOperationLayer[nextIndex], subStep.relatedOperationStroke[nextIndex])
        nextIndex += 1
        return result
    }
    
}

class StrokeArcIterator: IteratorProtocol {
    
    private let stroke: Stroke
    private var nextIndex: Int = 0
    
    init(stroke: Stroke) {
        self.stroke = stroke
    }
    
    func next() -> StrokeArc? {
        if nextIndex >= stroke.samples.count - 2 {
            return nil
        }
        let sampleBefore = stroke.samples[nextIndex]
        let sample = stroke.samples[nextIndex + 1]
        let sampleAfter = stroke.samples[nextIndex + 2]
        let strokeArc = StrokeArc(sampleBefore: sampleBefore, sample: sample, sampleAfter: sampleAfter)
        nextIndex += 1
        return strokeArc
    }
    
}
