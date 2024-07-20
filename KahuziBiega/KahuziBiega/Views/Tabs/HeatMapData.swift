//
//  HeatMapData.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/07/2024.
//

import Foundation
import UIKit
import MapKit
import CoreGraphics

class LFHeatMap {
    
    static func isqrt(_ x: Int) -> Int {
        let sqrttable: [Int] = [
            0, 16, 22, 27, 32, 35, 39, 42, 45, 48, 50, 53, 55, 57,
            59, 61, 64, 65, 67, 69, 71, 73, 75, 76, 78, 80, 81, 83,
            84, 86, 87, 89, 90, 91, 93, 94, 96, 97, 98, 99, 101, 102,
            103, 104, 106, 107, 108, 109, 110, 112, 113, 114, 115, 116, 117, 118,
            119, 120, 121, 122, 123, 124, 125, 126, 128, 128, 129, 130, 131, 132,
            133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 144, 145,
            146, 147, 148, 149, 150, 150, 151, 152, 153, 154, 155, 155, 156, 157,
            158, 159, 160, 160, 161, 162, 163, 163, 164, 165, 166, 167, 167, 168,
            169, 170, 170, 171, 172, 173, 173, 174, 175, 176, 176, 177, 178, 178,
            179, 180, 181, 181, 182, 183, 183, 184, 185, 185, 186, 187, 187, 188,
            189, 189, 190, 191, 192, 192, 193, 193, 194, 195, 195, 196, 197, 197,
            198, 199, 199, 200, 201, 201, 202, 203, 203, 204, 204, 205, 206, 206,
            207, 208, 208, 209, 209, 210, 211, 211, 212, 212, 213, 214, 214, 215,
            215, 216, 217, 217, 218, 218, 219, 219, 220, 221, 221, 222, 222, 223,
            224, 224, 225, 225, 226, 226, 227, 227, 228, 229, 229, 230, 230, 231,
            231, 232, 232, 233, 234, 234, 235, 235, 236, 236, 237, 237, 238, 238,
            239, 240, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246,
            246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253,
            253, 254, 254, 255
        ]
        
        var xn: Int
        
        if x >= 0x10000 {
            if x >= 0x1000000 {
                if x >= 0x10000000 {
                    if x >= 0x40000000 {
                        xn = sqrttable[x >> 24] << 8
                    } else {
                        xn = sqrttable[x >> 22] << 7
                    }
                } else {
                    if x >= 0x4000000 {
                        xn = sqrttable[x >> 20] << 6
                    } else {
                        xn = sqrttable[x >> 18] << 5
                    }
                }
            } else {
                if x >= 0x100000 {
                    if x >= 0x400000 {
                        xn = sqrttable[x >> 16] << 4
                    } else {
                        xn = sqrttable[x >> 14] << 3
                    }
                } else {
                    if x >= 0x40000 {
                        xn = sqrttable[x >> 12] << 2
                    } else {
                        xn = sqrttable[x >> 10] << 1
                    }
                }
            }
        } else {
            if x >= 0x100 {
                if x >= 0x1000 {
                    if x >= 0x4000 {
                        xn = (sqrttable[x >> 8] << 8) >> 8
                    } else {
                        xn = (sqrttable[x >> 6] << 8) >> 9
                    }
                } else {
                    if x >= 0x400 {
                        xn = (sqrttable[x >> 4] << 8) >> 10
                    } else {
                        xn = (sqrttable[x >> 2] << 8) >> 11
                    }
                }
            } else {
                xn = (sqrttable[x] << 8) >> 12
            }
        }
        
        xn = (xn + 1 + x / xn) >> 1
        xn = (xn + 1 + x / xn) >> 1
        xn = (xn + 1 + x / xn) >> 1
        
        return (xn * xn) > x ? xn - 1 : xn
    }
    
    
    static func heatMapForMapView(_ mapView: MKMapView?, boost: Float, locations: [CLLocation], weights: [NSNumber]) -> UIImage? {
        guard let mapView = mapView, !locations.isEmpty else {
            return nil
        }
        
        var points = [CGPoint]()
        for location in locations {
            let point = mapView.convert(location.coordinate, toPointTo: mapView)
            points.append(point)
        }
        
        return LFHeatMap.heatMapWithRect(mapView.frame, boost: boost, points: points, weights: weights)
    }
    
    static func heatMapWithRect(_ rect: CGRect, boost: Float, points: [CGPoint], weights: [NSNumber]) -> UIImage? {
        return LFHeatMap.heatMapWithRect(rect, boost: boost, points: points, weights: weights, weightsAdjustmentEnabled: false, groupingEnabled: true)
    }

    static func heatMapWithRect(_ rect: CGRect, boost: Float, points: [CGPoint], weights: [NSNumber]?, weightsAdjustmentEnabled: Bool, groupingEnabled: Bool) -> UIImage? {
        // Adjustment variables for weights adjustment
        let weightSensitivity: Float = 1 // Percents from maximum weight
        let weightBoostTo: Float = 50 // Percents to boost least sensible weight to
        
        // Adjustment variables for grouping
        let groupingThreshold: Int = 10 // Increasing this will improve performance with less accuracy. Negative will disable grouping
        let peaksRemovalThreshold: Int = 20 // Should be greater than groupingThreshold
        let peaksRemovalFactor: Float = 0.4 // Should be from 0 (no peaks removal) to 1 (peaks are completely lowered to zero)
        
        // Validate arguments
        if points.isEmpty || rect.size.width <= 0 || rect.size.height <= 0 || (weights != nil && points.count != weights?.count) {
            NSLog("LFHeatMap: heatMapWithRect: incorrect arguments")
            return nil
        }
        
        var image: UIImage? = nil
        let width = Int(rect.size.width)
        let height = Int(rect.size.height)
        
        // According to heatmap API, boost is heat radius multiplier
        let radius = Int(50 * boost)
        
        // RGBA array is initialized with 0s
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        var density = [Int](repeating: 0, count: width * height)
        
        // Step 1
        // Copy points into plain array (plain array iteration is faster than accessing NSArray objects)
        var pointsNum = points.count
        var pointX = [Int](repeating: 0, count: pointsNum)
        var pointY = [Int](repeating: 0, count: pointsNum)
        var pointWeightPercent = [Int](repeating: 0, count: pointsNum)
        var pointWeight: [Float]? = nil
        var maxWeight: Float = 0.0
        
        if let weights = weights {
            pointWeight = [Float](repeating: 0.0, count: pointsNum)
            maxWeight = 0.0
        }
        
        var i = 0
        var j = 0
        for pointValue in points {
            pointX[i] = Int(pointValue.x - rect.origin.x)
            pointY[i] = Int(pointValue.y - rect.origin.y)
            
            // Filter out of range points
            if pointX[i] < 0 - radius || pointY[i] < 0 - radius || pointX[i] >= Int(rect.size.width) + radius || pointY[i] >= Int(rect.size.height) + radius {
                pointsNum -= 1
                j += 1
                continue
            }
            
            // Fill weights if available
            if let weights = weights {
                let weightValue = weights[j]
                pointWeight?[i] = weightValue.floatValue
                if maxWeight < pointWeight![i] {
                    maxWeight = pointWeight![i]
                }
            }
            
            i += 1
            j += 1
        }
        
        // Step 1.5
        // Normalize weights to be 0 .. 100 (like percents)
        if var pointWeight = pointWeight {
            let absWeightSensitivity = (maxWeight / 100.0) * weightSensitivity
            let absWeightBoostTo = (maxWeight / 100.0) * weightBoostTo
            for i in 0..<pointsNum {
                if weightsAdjustmentEnabled {
                    if pointWeight[i] <= absWeightSensitivity {
                        pointWeight[i] *= absWeightBoostTo / absWeightSensitivity
                    } else {
                        pointWeight[i] = absWeightBoostTo + (pointWeight[i] - absWeightSensitivity) * ((maxWeight - absWeightBoostTo) / (maxWeight - absWeightSensitivity))
                    }
                }
                pointWeightPercent[i] = Int(100.0 * (pointWeight[i] / maxWeight))
            }
        } else {
            // Fill with 1 in case if no weights provided
            for i in 0..<pointsNum {
                pointWeightPercent[i] = 1
            }
        }
        
        // Step 1.75 (optional)
        // Grouping and filtering bunches of points in the same location
        if groupingEnabled {
            var i = 0
            while i < pointsNum {
                if pointWeightPercent[i] > 0 {
                    var j = i + 1
                    while j < pointsNum {
                        if pointWeightPercent[j] > 0 {
                            var currentDistance = sqrt(Double((pointX[i] - pointX[j]) * (pointX[i] - pointX[j]) + (pointY[i] - pointY[j]) * (pointY[i] - pointY[j])))
                            
                            if currentDistance > Double(peaksRemovalThreshold) {
                                currentDistance = Double(peaksRemovalThreshold)
                            }
                            
                            let K1: Float = 1 - peaksRemovalFactor
                            let K2: Float = peaksRemovalFactor
                            
                            // Lowering peaks
                            pointWeightPercent[i] = Int(Float(pointWeightPercent[i]) * K1 + Float(pointWeightPercent[i]) * K2 * Float(currentDistance) / Float(peaksRemovalThreshold))
                            
                            // Performing grouping if two points are closer than groupingThreshold
                            if currentDistance <= Double(groupingThreshold) {
                                // Merge i and j points. Store result in [i], remove [j]
                                pointX[i] = (pointX[i] + pointX[j]) / 2
                                pointY[i] = (pointY[i] + pointY[j]) / 2
                                pointWeightPercent[i] += pointWeightPercent[j]
                                
                                // pointWeightPercent[j] is set negative to be avoided
                                pointWeightPercent[j] = -10
                                
                                // Repeat again for the new point
                                i -= 1
                                break
                            }
                        }
                        j += 1
                    }
                }
                i += 1
            }
        }

//        if groupingEnabled {
//            for i in 0..<pointsNum {
//                if pointWeightPercent[i] > 0 {
//                    for j in i + 1..<pointsNum {
//                        if pointWeightPercent[j] > 0 {
//                            var currentDistance = sqrt(Double((pointX[i] - pointX[j]) * (pointX[i] - pointX[j]) + (pointY[i] - pointY[j]) * (pointY[i] - pointY[j])))
//                            
//                            if currentDistance > Double(peaksRemovalThreshold) {
//                                currentDistance = Double(peaksRemovalThreshold)
//                            }
//                            
//                            let K1: Float = 1 - peaksRemovalFactor
//                            let K2: Float = peaksRemovalFactor
//                            
//                            // Lowering peaks
//                            pointWeightPercent[i] = Int(Float(pointWeightPercent[i]) * K1 + Float(pointWeightPercent[i]) * K2 * Float(currentDistance) / Float(peaksRemovalThreshold))
//                            
//                            // Performing grouping if two points are closer than groupingThreshold
//                            if currentDistance <= Double(groupingThreshold) {
//                                // Merge i and j points. Store result in [i], remove [j]
//                                pointX[i] = (pointX[i] + pointX[j]) / 2
//                                pointY[i] = (pointY[i] + pointY[j]) / 2
//                                pointWeightPercent[i] += pointWeightPercent[j]
//                                
//                                // pointWeightPercent[j] is set negative to be avoided
//                                pointWeightPercent[j] = -10
//                                
//                                // Repeat again for the new point
//                                i -= 1
//                                break
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        // Step 2
        // Fill density info. Density is calculated around each point
        for i in 0..<pointsNum {
            if pointWeightPercent[i] > 0 {
                let fromX = max(0, pointX[i] - radius)
                let fromY = max(0, pointY[i] - radius)
                let toX = min(width, pointX[i] + radius)
                let toY = min(height, pointY[i] + radius)
                
                for y in fromY..<toY {
                    for x in fromX..<toX {
                        let currentDistance = (x - pointX[i]) * (x - pointX[i]) + (y - pointY[i]) * (y - pointY[i])
                        var currentDensity = radius - Int(sqrt(Double(currentDistance)))
                        if currentDensity < 0 {
                            currentDensity = 0
                        }
                        
                        density[y * width + x] += currentDensity * pointWeightPercent[i]
                    }
                }
            }
        }
        
        // Step 2.5
        // Find max density (doing this in step 2 will have less performance)
        let maxDensity = density.max() ?? 0
        
        // Step 3
        // Render density info into raw RGBA pixels
        for i in 0..<(width * height) {
            if density[i] > 0 {
                let floatDensity = Float(density[i]) / Float(maxDensity)
                rgba[4 * i] = UInt8(floatDensity * 255)
                rgba[4 * i + 3] = rgba[4 * i]
                
                // Green component
                if floatDensity >= 0.75 {
                    rgba[4 * i + 1] = rgba[4 * i]
                } else if floatDensity >= 0.5 {
                    rgba[4 * i + 1] = UInt8((floatDensity - 0.5) * 255 * 3)
                }
                
                // Blue component
                if floatDensity >= 0.8 {
                    rgba[4 * i + 2] = UInt8((floatDensity - 0.8) * 255 * 5)
                }
            }
        }
        
        // Step 4
        // Create image from rendered raw data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmapContext = CGContext(data: &rgba, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        guard let cgImage = bitmapContext.makeImage() else {
            return nil
        }
        
        image = UIImage(cgImage: cgImage)
        
        return image
    }

    

//    static func heatMap(for mapView: MKMapView, boost: Float, locations: [CLLocation], weights: [NSNumber]) -> UIImage? {
//        let rect = mapView.bounds
//        let mapSize = rect.size
//
//        print("Reaching1")
//        // Step 1: Determine the max radius
//        let maxRadius = Int(locations.map { $0.coordinate.latitude }.max() ?? 0)
//
//        print("Reaching2")
//        // Step 2: Create a density map
//        let width = Int(mapSize.width)
//        let height = Int(mapSize.height)
//        var density = [Int](repeating: 0, count: width * height)
//
//        print("Reaching3", mapView.frame)
//        // Step 3: Calculate the density
//        for (i, location) in locations.enumerated() {
//            let point = mapView.convert(location.coordinate, toPointTo: mapView)
//            let weight = weights[i].intValue
//            let boostRadius = Int(location.coordinate.latitude)
//
//            let radius = min(boostRadius, maxRadius)
//            let x0 = max(Int(point.x) - radius, 0)
//            let x1 = min(Int(point.x) + radius, width - 1)
//            let y0 = max(Int(point.y) - radius, 0)
//            let y1 = min(Int(point.y) + radius, height - 1)
//
//            print("RR", y0, y1)
//            print("CHCKC", x0, x1)
//            for y in y0...y1 {
//                for x in x0...x1 {
//                    let dx = x - Int(point.x)
//                    let dy = y - Int(point.y)
//                    let distanceSquared = dx * dx + dy * dy
//                    if distanceSquared < radius * radius {
//                        let index = y * width + x
//                        density[index] += weight
//                    }
//                }
//            }
//        }
//
//        print("Reaching4")
//        // Step 4: Find the maximum density
//        let maxDensity = density.max() ?? 0
//        print("Reaching5")
//        // Step 5: Create the image data
//        var rgba = [UInt8](repeating: 0, count: width * height * 4)
//        var i = 0
//        for y in 0..<height {
//            for x in 0..<width {
//                if density[i] > 0 {
//                    let indexOrigin = 4 * i
//                    // Normalize density to 0..1
//                    let floatDensity = Float(density[i]) / Float(maxDensity)
//
//                    // Red and alpha component
//                    rgba[indexOrigin] = UInt8(floatDensity * 255)
//                    rgba[indexOrigin + 3] = rgba[indexOrigin]
//
//                    // Green component
//                    if floatDensity >= 0.75 {
//                        rgba[indexOrigin + 1] = rgba[indexOrigin]
//                    } else if floatDensity >= 0.5 {
//                        rgba[indexOrigin + 1] = UInt8((floatDensity - 0.5) * 255 * 3)
//                    }
//
//                    // Blue component
//                    if floatDensity >= 0.8 {
//                        rgba[indexOrigin + 2] = UInt8((floatDensity - 0.8) * 255 * 5)
//                    }
//                }
//                i += 1
//            }
//        }
//        
//        print("Reaching6")
//
//        // Step 6: Create image from rendered raw data
//        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
//              let context = CGContext(data: &rgba,
//                                      width: width,
//                                      height: height,
//                                      bitsPerComponent: 8,
//                                      bytesPerRow: 4 * width,
//                                      space: colorSpace,
//                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
//              let cgImage = context.makeImage() else {
//            return nil
//        }
//
//        return UIImage(cgImage: cgImage)
//    }
}
