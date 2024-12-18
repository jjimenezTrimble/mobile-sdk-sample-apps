import Foundation
import UIKit
import TrimbleMaps
import TrimbleMapsAccounts

class DotsOnAMapViewController: UIViewController, AccountManagerDelegate, TMGLMapViewDelegate {

    internal var mapView: TMGLMapView!

    let SOURCE_ID = "tristatepoints"
    let LAYER_ID = "tristatepoints"

    override func viewDidLoad() {
        super.viewDidLoad()
        let apiKey =  "Your-API-key-here"
        let account = Account(apiKey: apiKey, region: Region.northAmerica)
        AccountManager.default.account = account
        AccountManager.default.delegate = self
    }

    func stateChanged(newStatus: AccountManagerState) {
        if newStatus == .loaded {
            DispatchQueue.main.async {
                // Create a map view
                self.mapView = TMGLMapView(frame: self.view.bounds)
                self.mapView.delegate = self

                // Set the map location
                let center = CLLocationCoordinate2D(latitude: 41.36290180612575, longitude: -74.6946761628674)
                self.mapView.setCenter(center, zoomLevel: 13, animated: false)

                // Add the map
                self.view.addSubview(self.mapView)
            }
        }
    }

    func mapViewDidFinishLoadingMap(_ mapView: TMGLMapView) {
        // In this example a .json file is being used as the source

        let filePath = Bundle.main.path(forResource: "tristate", ofType: "json")!
        let fileUrl = URL(fileURLWithPath: filePath)

        // Create a source and add it to the style. Important to note, sources are linked to styles.
        // If you change the style you may need to re-add your source and layers
        let shapeSource = TMGLShapeSource(identifier: SOURCE_ID, url: fileUrl, options: .none)
        mapView.style?.addSource(shapeSource)

        // Create a CircleLayer to display our source information.
        let circleLayer = TMGLCircleStyleLayer(identifier: LAYER_ID, source: shapeSource)
        circleLayer.circleRadius = NSExpression(forConstantValue: 4)
        circleLayer.circleColor = NSExpression(forConstantValue: UIColor.red)

        // add the layer
        mapView.style?.addLayer(circleLayer)

    }

}

