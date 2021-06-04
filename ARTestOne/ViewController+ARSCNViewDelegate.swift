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
       
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print(node)
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        self.planeNode = node
        self.planeAnchor = planeAnchor
        DispatchQueue.main.async {
            self.addButton.isHidden = false
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
