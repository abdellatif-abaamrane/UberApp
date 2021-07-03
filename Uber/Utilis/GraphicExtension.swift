//
//  GraphicExtension.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import UIKit

extension CGMutablePath {
    //    func simpleSmooth (points: [CGPoint]) {
    //        guard points.count > 1 else { return nil }
    //        move(to: points[0])
    //
    //        var index = 0
    //
    //        while index < (points.count - 1) {
    //            switch (points.count - index) {
    //            case 2:
    //                index += 1
    //                addLine(to: points[index])
    //            case 3:
    //                index += 2
    //                addQuadCurve(to: points[index], controlPoint: points[index-1])
    //            case 4:
    //                index += 3
    //                addCurve(to: points[index], controlPoint1: points[index-2], controlPoint2: points[index-1])
    //            default:
    //                index += 3
    //                let point = CGPoint(x: (points[index-1].x + points[index+1].x) / 2,
    //                                    y: (points[index-1].y + points[index+1].y) / 2)
    //                addCurve(to: point, controlPoint1: points[index-2], controlPoint2: points[index-1])
    //            }
    //        }
    //    }
    //    func hermiteInterpolatedPoints( points: [CGPoint], closed: Bool) {
    //        guard points.count > 1 else { return nil }
    //
    //        let numberOfCurves = closed ? points.count : points.count - 1
    //
    //        var previousPoint: CGPoint? = closed ? points.last : nil
    //        var currentPoint:  CGPoint  = points[0]
    //        var nextPoint:     CGPoint? = points[1]
    //
    //        move(to: currentPoint)
    //
    //        for index in 0 ..< numberOfCurves {
    //            let endPt = nextPoint!
    //
    //            var mx: CGFloat
    //            var my: CGFloat
    //
    //            if previousPoint != nil {
    //                mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x)*0.5
    //                my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y)*0.5
    //            } else {
    //                mx = (nextPoint!.x - currentPoint.x) * 0.5
    //                my = (nextPoint!.y - currentPoint.y) * 0.5
    //            }
    //
    //            let ctrlPt1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
    //
    //            previousPoint = currentPoint
    //            currentPoint = nextPoint!
    //            let nextIndex = index + 2
    //            if closed {
    //                nextPoint = points[nextIndex % points.count]
    //            } else {
    //                nextPoint = nextIndex < points.count ? points[nextIndex % points.count] : nil
    //            }
    //
    //            if nextPoint != nil {
    //                mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x) * 0.5
    //                my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y) * 0.5
    //            }
    //            else {
    //                mx = (currentPoint.x - previousPoint!.x) * 0.5
    //                my = (currentPoint.y - previousPoint!.y) * 0.5
    //            }
    //
    //            let ctrlPt2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
    //
    //            addCurve(to: endPt, controlPoint1: ctrlPt1, controlPoint2: ctrlPt2)
    //        }
    //
    //        if closed { close() }
    //    }
    //    func interpolatePointsWithHermitee(quadCurve points: [CGPoint]) {
    //        guard points.count > 1 else { return }
    //
    //        var p1 = points[0]
    //        move(to: p1)
    //
    //        if points.count == 2 {
    //            addLine(to: points[1])
    //        }
    //
    //        for i in 0..<points.count {
    //            let mid = midPoint(p1: p1, p2: points[i])
    //
    //            addQuadCurve(to: mid, control: controlPoint(p1: mid, p2: p1))
    //            addQuadCurve(to: points[i], control: controlPoint(p1: mid, p2: points[i]))
    //
    //            p1 = points[i]
    //        }
    //    }
    //    private func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
    //        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    //    }
    //
    //    private func controlPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
    //        var controlPoint = midPoint(p1: p1, p2: p2)
    //        let diffY = abs(p2.y - controlPoint.y)
    //
    //        if p1.y < p2.y {
    //            controlPoint.y += diffY
    //        } else if p1.y > p2.y {
    //            controlPoint.y -= diffY
    //        }
    //        return controlPoint
    //    }
    //    func interpolatePointsWithHermite(interpolationPoints : [CGPoint], alpha : CGFloat = 1.0/3.0) {
    //
    //        guard !interpolationPoints.isEmpty else { return }
    //        self.move(to: interpolationPoints[0])
    //
    //        let n = interpolationPoints.count - 1
    //
    //        for index in 0..<n {
    //            var currentPoint = interpolationPoints[index]
    //            var nextIndex = (index + 1) % interpolationPoints.count
    //            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
    //            var previousPoint = interpolationPoints[prevIndex]
    //            var nextPoint = interpolationPoints[nextIndex]
    //            let endPoint = nextPoint
    //            var mx: CGFloat
    //            var my: CGFloat
    //
    //            if index > 0 {
    //                mx = (nextPoint.x - previousPoint.x) / 2.0
    //                my = (nextPoint.y - previousPoint.y) / 2.0
    //            }
    //            else {
    //                mx = (nextPoint.x - currentPoint.x) / 2.0
    //                my = (nextPoint.y - currentPoint.y) / 2.0
    //            }
    //
    //            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
    //            currentPoint = interpolationPoints[nextIndex]
    //            nextIndex = (nextIndex + 1) % interpolationPoints.count
    //            prevIndex = index
    //            previousPoint = interpolationPoints[prevIndex]
    //            nextPoint = interpolationPoints[nextIndex]
    //
    //            if index < n - 1 {
    //                mx = (nextPoint.x - previousPoint.x) / 2.0
    //                my = (nextPoint.y - previousPoint.y) / 2.0
    //            }
    //            else {
    //                mx = (currentPoint.x - previousPoint.x) / 2.0
    //                my = (currentPoint.y - previousPoint.y) / 2.0
    //            }
    //
    //            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
    //            self.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
    //        }
    //    }
    func catmullRomInterpolatedPoints( points: [CGPoint], closed: Bool, alpha: CGFloat) {
        guard points.count > 3 else { return }
        assert(alpha >= 0 && alpha <= 1.0, "Alpha must be between 0 and 1")
        
        let endIndex = closed ? points.count : points.count - 2
        
        let startIndex = closed ? 0 : 1
        
        let kEPSILON: CGFloat = 1.0e-5
        
        move(to: points[startIndex])
        
        for index in startIndex ..< endIndex {
            let nextIndex = (index + 1) % points.count
            let nextNextIndex = (nextIndex + 1) % points.count
            let previousIndex = index < 1 ? points.count - 1 : index - 1
            
            let point0 = points[previousIndex]
            let point1 = points[index]
            let point2 = points[nextIndex]
            let point3 = points[nextNextIndex]
            
            let d1 = hypot(CGFloat(point1.x - point0.x), CGFloat(point1.y - point0.y))
            let d2 = hypot(CGFloat(point2.x - point1.x), CGFloat(point2.y - point1.y))
            let d3 = hypot(CGFloat(point3.x - point2.x), CGFloat(point3.y - point2.y))
            
            let d1a2 = pow(d1, alpha * 2)
            let d1a  = pow(d1, alpha)
            let d2a2 = pow(d2, alpha * 2)
            let d2a  = pow(d2, alpha)
            let d3a2 = pow(d3, alpha * 2)
            let d3a  = pow(d3, alpha)
            
            var controlPoint1: CGPoint, controlPoint2: CGPoint
            
            if abs(d1) < kEPSILON {
                controlPoint1 = point2
            } else {
                controlPoint1 = (point2 * d1a2 - point0 * d2a2 + point1 * (2 * d1a2 + 3 * d1a * d2a + d2a2)) / (3 * d1a * (d1a + d2a))
            }
            
            if abs(d3) < kEPSILON {
                controlPoint2 = point2
            } else {
                controlPoint2 = (point1 * d3a2 - point3 * d2a2 + point2 * (2 * d3a2 + 3 * d3a * d2a + d2a2)) / (3 * d3a * (d3a + d2a))
            }
            
            addCurve(to: point2, control1: controlPoint1, control2: controlPoint2)
                if closed { closeSubpath() }
        }
        
    }
}
func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * CGFloat(rhs))
}

func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / CGFloat(rhs))
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
