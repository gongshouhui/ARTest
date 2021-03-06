//
//  viewController+ARSCNViewDelegate.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/6/4.
//

import ARKit
extension ViewController: ARSCNViewDelegate,ARSessionDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        return SCNNode()
//    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: self.virtualObjectArray.count > 0 ? true : false)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        print("平面识别")
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        print("dddd",planeAnchor.extent)
        //平面节点识别出来后，这个节点的锚点不会变化，会识别多个平面
        if self.currentGraph?.planeNode == nil {
            DispatchQueue.main.async {
                //检测平面锚点，直接添加模型
                let graph = GraphInfo()
                graph.planeNode = node
                graph.planeAnchor = planeAnchor
                graph.addVirualObject()
                self.virtualObjectArray.append(graph)
                self.currentGraph = graph
                self.addButton.isHidden = false
            }
           
        }
      
        
        
        
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }

        DispatchQueue.main.async {
            //检测平面锚点，直接添加模型
            self.currentPlaneNode = node
            self.currentPlaneAnchor = planeAnchor
            
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
