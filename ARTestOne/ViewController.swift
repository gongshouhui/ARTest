//
//  ViewController.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/19.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    //取hitTest命中的节点
    var movedNode: SCNNode?
    var rotateNode: RotateNode?
    var planeNode: SCNNode?
    var planeAnchor: ARPlaneAnchor?
    var nodeArray = [SCNNode]()
    
    
    
    lazy var arSessionConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
    lazy var cupScene: SCNScene? = {
        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
        return cupScene
    }()
    lazy var bottomNode: BottomNode = {
        let bottomNode = BottomNode()
        return bottomNode
    }()
    
    
    @IBAction func addButton(_ sender: UIButton) {
   
        
        //获取模型场景
        //SCNNode
        let cupNode = self.cupScene?.rootNode.childNodes.first
        self.nodeArray.append(cupNode!)
        print("cupnode",cupNode?.width(),cupNode?.length(),cupNode?.name)
        
        
        cupNode?.position = SCNVector3(self.planeAnchor!.center.x, 0, self.planeAnchor!.center.z)
        self.bottomNode.scale = SCNVector3(3, 1, 3)
        self.bottomNode.position = SCNVector3(0, -0.03,0)
        let modelNode = ModelNode()
        modelNode.position = SCNVector3(0,0,0)
        modelNode.addChildNode(cupNode!)
        modelNode.addChildNode(self.bottomNode)
        self.planeNode!.addChildNode(modelNode)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //sceneView.allowsCameraControl = true
        addButton.isHidden = true
        //        let bottomNode = BottomNode()
        //        //y方向scale设置为零后，hitTest捕捉不到节点
        //        //bottomNode.scale = SCNVector3(1.5, 0, 1.5)
        //        bottomNode.position = SCNVector3(0, -0.2, -0.3)
        //        sceneView.scene.rootNode.addChildNode(bottomNode)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
  
 

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuratio
        
        // Run the view's session
        sceneView.session.run(self.arSessionConfiguration)
        self.virtualObjectInteraction.current = nil
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.virtualObjectInteraction.touchesBegan(touches, with: event)
        
    }
   

}

extension SCNNode {
    func width() -> Float {
        return boundingBox.max.x - boundingBox.min.x
    }
    func length() -> Float {
        return boundingBox.max.z - boundingBox.min.z
    }
    
}
