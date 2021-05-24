//
//  SegmentNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
class SegmentNode: SCNNode {
    /// Thickness of the focus square lines in m.
    /// 聚焦框线段的线宽,单位是米.
    static let thickness: CGFloat = 0.1

    /// Length of the focus square lines in m.
    /// 聚焦框线段的线长,单位是米
    static let length: CGFloat = 0.02  // segment length

    let alignment: Alignment
    let plane: SCNBox
    init(name: String, alignment: Alignment) {
        self.alignment = alignment
        switch alignment {
        case .vertical:
            
            plane = SCNBox(width: SegmentNode.length, height: 0, length: SegmentNode.thickness - RotateNode.radius, chamferRadius: 0)
        case .horizontal:
            plane = SCNBox(width: SegmentNode.thickness - RotateNode.radius, height: 0, length: SegmentNode.length, chamferRadius: 0)
        }
        super.init()
        self.name = name
        self.opacity = 0.7
        
        let material = plane.firstMaterial!
        material.diffuse.contents = BottomNode.primaryColor
//        material.isDoubleSided = true
//        material.ambient.contents = UIColor.black
//        material.lightingModel = .constant
//        material.emission.contents = BottomNode.primaryColor
        geometry = plane
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
