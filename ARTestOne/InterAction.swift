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
    
     var current: SCNVector3?
     var lastPoint: SCNVector3?
    var newAngleY: CGFloat = 0.0

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
        
        switch gesture.state {
        case .began:
            let arResults = self.sceneView.hitTest(gesture.location(in: sceneView), types: .existingPlane)
            //获取点的世界坐标
            if arResults.last != nil {
                let currentSimd4 = arResults.last!.worldTransform
                
                let currentVector = SCNVector3(currentSimd4.columns.3.x, currentSimd4.columns.3.y, currentSimd4.columns.3.z)
                lastPoint = currentVector
            }
          
            
//
//            let SCNHitResults:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(in: self.sceneView), options: nil))!
//            guard SCNHitResults.count > 0 else{
//                return
//            }
//            if let node = SCNHitResults.first?.node as? RotateNode {//命中旋转小节点,做旋转
//
//                if self.rotateNode == nil {//一次拖动只取第一次命中的节点
//                    self.rotateNode = node
//                }
//
//                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow_red")
//            } else {
//                if let node = SCNHitResults.first?.node {
//                    movedNode = getModelNode(node: node)
//                }
//            }
            break
        case .changed:
            //旋转 ,首先选中旋转小节点
            if self.viewController.currentGraph?.rotateNode != nil { //根据坐标计算角度
                //旋转
                let arResults = self.sceneView.hitTest(gesture.location(in: sceneView), types: .existingPlane)
                if arResults.last != nil {
                    //获取点的世界坐标
                    let currentSimd4 = arResults.last!.worldTransform
                    
                    let currentVector = SCNVector3(currentSimd4.columns.3.x, currentSimd4.columns.3.y, currentSimd4.columns.3.z)
                    current = currentVector
                    if lastPoint != nil {
                        let angel = getAngle(from: lastPoint!, to: current!, yuandian: self.viewController.currentGraph?.virtualObject?.worldPosition ?? SCNVector3(0.0, 0.0, 0.0))
                       
                        let parentNode = self.viewController.currentGraph?.virtualObject
                        //let transtion = gesture.translation(in: gesture.view)
                        let clockwise = isClockwise(yuandian: self.viewController.currentGraph?.virtualObject?.worldPosition ?? SCNVector3(0.0, 0.0, 0.0), from: lastPoint!, to: current!)
                     
                        if  !clockwise {
                            self.newAngleY =  angel
                            self.newAngleY += self.viewController.currentGraph!.currentAngleY
                            
                        } else {
                            self.newAngleY =  -angel
                            self.newAngleY += self.viewController.currentGraph!.currentAngleY
                            //                        let rotationAcrion =  SCNAction.rotateBy(x: 0, y: -angel, z: 0, duration: 0)
                            //                        parentNode!.runAction(rotationAcrion)
                        }
                        parentNode?.eulerAngles.y = Float(self.newAngleY)
                    }
                    
                    lastPoint = current
                    self.viewController.currentGraph!.currentAngleY = self.newAngleY
                    //旋转和移动只有一个生效
                    return
                }
             
            }
            
            //            //旋转 ,首先选中旋转小节点
            //                if self.rotateNode != nil { //可根据拖动距离旋转
            //                    let parentNode = self.rotateNode?.parent?.parent;
            //                    let transtion = gesture.translation(in: gesture.view)
            //                    self.newAngleY =  CGFloat(transtion.x) * (CGFloat) (Double.pi)/180
            //                    self.newAngleY += self.currentAngleY
            //                    parentNode?.eulerAngles.y = Float(self.newAngleY)
            //                    //旋转和移动只有一个生效
            //                    return
            //                }
            if  self.viewController.currentGraph?.movedNode != nil {//做移动动作

                let ARHitResults: [ARHitTestResult] = self.sceneView.hitTest(gesture.location(in: self.sceneView), types: .existingPlane)
                guard let lastResult = ARHitResults.last else {
                   return
                }
                let simd4 = lastResult.worldTransform
                let vector = SCNVector3(simd4.columns.3.x,  self.viewController.currentGraph!.planeNode!.worldPosition.y, simd4.columns.3.z)
//                let tranx = vector.x - self.viewController.movedNode!.worldPosition.x
//                let tranz = vector.z - self.viewController.movedNode!.worldPosition.z
//                self.viewController.movedNode!.transform.m41 = self.viewController.movedNode!.transform.m41 + tranx
//                self.viewController.movedNode!.transform.m43 = self.viewController.movedNode!.transform.m43 + tranz
                
                
                
                self.viewController.currentGraph!.virtualObject!.worldPosition = vector;
            }
            
        case .ended:
            
            //旋转完颜色恢复
            if self.viewController.currentGraph!.rotateNode != nil {
                self.viewController.currentGraph!.rotateNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow")
                self.viewController.currentGraph!.rotateNode = nil;
            }
            self.viewController.currentGraph?.movedNode = nil
            
        default:
            break
        }
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.viewController.currentGraph?.currentAngleY = self.newAngleY
            lastPoint = nil
        }
    }
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    let touch = touches.first;
   
    let SCNHitResults:[SCNHitTestResult] = sceneView.hitTest((touch?.location(in: sceneView))!, options: nil)
    guard SCNHitResults.count > 0 else{
        for graph in self.viewController.virtualObjectArray {
            
            graph.virtualObject?.isSelected = false
        }
       
        return
    }
    
        if let virtualObject = SCNHitResults.first?.node {
            
            let selectedNode = getModelNode(node: virtualObject)
            
            if selectedNode != nil {
                //获取当前可操作场景
                for graph in self.viewController.virtualObjectArray {
                    if graph.virtualObject == selectedNode {
                        graph.virtualObject?.isSelected = true
                        self.viewController.currentGraph = graph
                    }
                }
            } else {
                for graph in self.viewController.virtualObjectArray {
                    
                    graph.virtualObject?.isSelected = false
                }
            }
        }

    if let node = SCNHitResults.first?.node as? RotateNode {//命中旋转小节点,做旋转
        
        if self.viewController.currentGraph?.rotateNode == nil {//一次拖动只取第一次命中的节点
            self.viewController.currentGraph?.rotateNode = node
        }
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow_red")
    } else {
        if let node = SCNHitResults.first?.node {
            self.viewController.currentGraph?.movedNode = getModelNode(node: node)
        }
    }
    
    
    }
    
    func updatedTrackingPosition(for object: VirtualObject, from gesture: UIPanGestureRecognizer) -> CGPoint {
        let translation = gesture.translation(in: sceneView)
        
        let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
        let updatedPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
        currentTrackingPosition = updatedPosition
        return updatedPosition
    }
   
  
    //如果有父节点返回父节点,没有返回自己
    private func getModelNode(node: SCNNode) -> VirtualObject? {
        if let modelNode = node as? VirtualObject {
            return modelNode
        }
        guard let parentNode = node.parent else {
            return nil
        }
        return getModelNode(node: parentNode)
    }
    private func isClockwise(yuandian p1: SCNVector3,from p2: SCNVector3,to p3: SCNVector3) -> Bool {
        //        p1=(x1,y1), p2=(x2,y2), p3=(x3,y3) 求向量 p12=(x2-x1,y2-y1) p23=(x3-x2,y3-y2) 则当 p12 与 p23 的叉乘（向量积） p12 x p23 = (x2-x1)*(y3-y2)-(y2-y1)*(x3-x2)
        let p12 = (p2.x - p1.x,p2.z - p1.z)
        let p23 = (p3.x - p2.x,p3.z - p2.z)
        let value = p12.0 * p23.1 - p12.1 * p23.0
        return value > 0
    }
    private func getAngle(from: SCNVector3,to: SCNVector3,yuandian: SCNVector3) -> CGFloat {
        let x1 = from.x - yuandian.x
        let z1 = from.z - yuandian.z
        let x2 = to.x - yuandian.x
        let z2 = to.z - yuandian.z
        let x = x1 * x2 + z1 * z2
        let z = x1 * z2 - x2 * z1
        let angel = acos(x/sqrt(x * x + z * z))
        return CGFloat(angel)
    }
}



