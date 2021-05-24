//
//  BottomNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
import ARKit
enum Corner {
    case topLeft // s1, s3
    case topRight // s2, s4
    case bottomRight // s6, s8
    case bottomLeft // s5, s7
}
enum SegmentDirection {
    case Left // s1, s3
    case Right // s2, s4
    case top // s6, s8
    case bottom // s5, s7
}

enum Alignment {
    case horizontal // s1, s2, s7, s8
    case vertical // s3, s4, s5, s6
}

enum Direction {
    case up, down, left, right

    var reversed: Direction {
        switch self {
            case .up:   return .down
            case .down: return .up
            case .left:  return .right
            case .right: return .left
        }
    }
}
class BottomNode: SCNNode {
    static let primaryColor = UIColor.gray
    override init() {
        super.init()
        let rotate1 = RotateNode(name: "leftTop")
        let rotate2 = RotateNode(name: "leftBottom")
        let rotate3 = RotateNode(name: "rightTop")
        let rotate4 = RotateNode(name: "rightBottom")
        
        let segment1 = SegmentNode(name: "left", alignment: .vertical)
        let segment2 = SegmentNode(name: "top", alignment: .horizontal)
        let segment3 = SegmentNode(name: "right", alignment: .vertical)
        let segment4 = SegmentNode(name: "bottom", alignment: .horizontal)
        let nodes = [rotate1,rotate2,rotate3,rotate4,segment1,segment2,segment3,segment4]
        let length: CGFloat = SegmentNode.thickness //segment length 线段长
        //position是相对于父节点的位置，默认（0，0，0）
        rotate1.position = SCNVector3(-length/2, 0, -length/2)
        rotate2.position = SCNVector3(-length/2, 0, length/2)
        rotate3.position = SCNVector3(length/2, 0, -length/2)
        rotate4.position = SCNVector3(length/2, 0, length/2)
        segment1.position = SCNVector3(-length/2, 0, 0)
        segment2.position = SCNVector3(0, 0, -length/2)
        segment3.position = SCNVector3(length/2, 0, 0)
        segment4.position = SCNVector3(0, 0, length/2)
        
    
        
        for segment in nodes {
            addChildNode(segment)
        }
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
