/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

// MARK: - float4x4 extensions

extension float4x4 {

    
     // 列主序平移矩阵
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
     // 四元数矩阵
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    
    // 缩放矩阵
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
    
    
    // 绕Y轴旋转
    /*
                顺时针
                                            
     | cos(angle) 0 sin(angle)|             
     |      0     1    0      |
     |-sin(angle) 0 cos(angle)|
     
     
                逆时针
     
     |cos(angle) 0 -sin(angle)|
     |    0      1       0    |
     |sin(angle) 0  cos(angle)|
     
                                    */
    
    func makeRotationYMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), 0, -sin(angle)),
            simd_float3(0, 1, 0),
            simd_float3(-sin(angle), 0, cos(angle))
        ]
        return float3x3(rows: rows)
    }
}


///// Retrieve euler angles from a quaternion matrix
//public var eulerAngles: SCNVector3 {
//    get {
//        //first we get the quaternion from m00...m22
//        let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
//        let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
//        let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
//        let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)
//
//        //then we deduce euler angles with some cosines
//        // roll (x-axis rotation)
//        let sinr = +2.0 * (qw * qx + qy * qz)
//        let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
//        let roll = atan2(sinr, cosr)
//
//        // pitch (y-axis rotation)
//        let sinp = +2.0 * (qw * qy - qz * qx)
//        var pitch: Float
//        if fabs(sinp) >= 1 {
//             pitch = copysign(Float.pi / 2, sinp)
//        } else {
//            pitch = asin(sinp)
//        }
//
//        // yaw (z-axis rotation)
//        let siny = +2.0 * (qw * qz + qx * qy)
//        let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
//        let yaw = atan2(siny, cosy)
//
//        return SCNVector3(pitch, yaw, roll)
//    }
//}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    // 向量模
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}
