//
//  InterAction.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/6/4.
//
import UIKit
import ARKit
class VirtualObjectInteraction: NSObject, UIGestureRecognizerDelegate {
    
    /// The scene view to hit test against when moving virtual content.
    let sceneView: ARSCNView
    
    /// A reference to the view controller.
    let viewController: ViewController
    
    /**
     The object that has been most recently intereacted with.
     The `selectedObject` can be moved at any time with the tap gesture.
     */
    var selectedObject: ModelNode?
    
    /// The tracked screen position used to update the `trackedObject`'s position.
    private var currentTrackingPosition: CGPoint?
    
    init(sceneView: ARSCNView, viewController: ViewController) {
        self.sceneView = sceneView;
        self.viewController = viewController;
        super.init()
        //添加平移手势
        //scnview 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        self.sceneView.addGestureRecognizer(pan)
    }
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        
    }
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//    let touch = touches.first;
//   
//    let SCNHitResults:[SCNHitTestResult] = sceneView.hitTest((touch?.location(in: sceneView))!, options: nil)
//    guard SCNHitResults.count > 0 else{
//        return
//    }
//    if let node = SCNHitResults.first?.node as? RotateNode {//命中旋转小节点,做旋转
//        
//        if self.rotateNode == nil {//一次拖动只取第一次命中的节点
//            self.rotateNode = node
//        }
//        
//        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow_red")
//    } else {
//        if let node = SCNHitResults.first?.node {
//            movedNode = getModelNode(node: node)
//        }
//    }
    
    
    }
}
