//
//  ViewController.swift
//  AR ruler
//
//  Created by Ali KINU on 15.04.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let configuration = ARWorldTrackingConfiguration() // Create a session configuration
        sceneView.session.run(configuration)  // Run the view's session
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(hitAt : hitResult)
            }
        }
    }
    func addDot (hitAt hitResult :  ARHitTestResult ){
        
        let dotGeometry = SCNSphere(radius: 0.003)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3( // get the position where you tab on and pass in diceNode.position-> now it's got a  position
            
            hitResult.worldTransform[3][0],
            
            hitResult.worldTransform[3][1],
            
            hitResult.worldTransform[3][2])
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
        
    }
    func calculate() {
        let startPoint = dotNodes[0]
        let endPoint = dotNodes[1]
        let distance = sqrt(
            pow(endPoint.position.x - startPoint.position.x,2) +
            pow(endPoint.position.y - startPoint.position.y,2) +
            pow(endPoint.position.z - startPoint.position.z,2)
        )
        update(text : "\(abs(distance))", atPosition: endPoint.position)
    }
    
    func update(text:String, atPosition position: SCNVector3 ) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
        
}
