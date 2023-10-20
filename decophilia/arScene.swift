//
//  arScene.swift
//  decophilia
//
//  Created by Diego Asua on 10/16/23.
//

import ARKit
import SwiftUI

struct ARImageView: View {
    var imageName: String

    var body: some View {
        ARKitView(imageName: imageName)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARKitView: UIViewRepresentable {
    var imageName: String

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator

        // Add gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPan(_:)))
        arView.addGestureRecognizer(panGesture)

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal

            uiView.session.run(configuration)

            // Add 2D image to the AR scene
            let image = UIImage(named: imageName)!
            let plane = SCNPlane(width: 1.0, height: 1.0 * CGFloat(image.size.height / image.size.width))
            plane.firstMaterial?.diffuse.contents = image
            let node = SCNNode(geometry: plane)
            uiView.scene.rootNode.addChildNode(node)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARKitView
        var isNodeSelected: Bool = false
        var selectedNode: SCNNode?

        init(_ parent: ARKitView) {
            self.parent = parent
        }

        @objc func didPan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = gesture.view as? ARSCNView else { return }

            let location = gesture.location(in: arView)

            switch gesture.state {
            case .began:
                handleTouchFor(in: arView, location: location)

            case .changed:
                if isNodeSelected, let selectedNode = selectedNode {
                    let hitTestResults = arView.hitTest(location, types: .existingPlaneUsingExtent)
                    if let hitTest = hitTestResults.first {
                        let position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
                        selectedNode.position = position
                    }
                } else {
                    handleTouchFor(in: arView, location: location)
                }

            case .ended:
                isNodeSelected = false

            default:
                break
            }
        }

        func handleTouchFor(in view: ARSCNView, location: CGPoint) {
            let hitResults = view.hitTest(location, options: nil)
            if let hit = hitResults.first, hit.node.geometry is SCNPlane {
                selectedNode = hit.node
                isNodeSelected = true
            } else {
                isNodeSelected = false
            }
        }
    }
}

