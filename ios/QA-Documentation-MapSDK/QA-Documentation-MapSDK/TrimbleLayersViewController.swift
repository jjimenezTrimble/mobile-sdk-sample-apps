import Foundation
import UIKit
import TrimbleMaps
import TrimbleMapsAccounts

class TrimbleLayersViewController: UIViewController, AccountManagerDelegate {

    internal var mapView: TMGLMapView!

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

                // Set the map location
                let center = CLLocationCoordinate2D(latitude: 40.7584766, longitude: -73.9840227)
                self.mapView.setCenter(center, zoomLevel: 13, animated: false)

                // Add the map
                self.view.addSubview(self.mapView)

                // Add the layer buttons
                self.addLayerButtons()
            }
        }
    }

    private func addLayerButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        button.backgroundColor = .gray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10.0

        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        self.mapView.addSubview(button)

        return button
    }

    func addLayerButtons() {
        let trafficButton = addLayerButton(title: "Traffic", action: #selector(trafficButtonPressed))
        let buildingsButton = addLayerButton(title: "3D Buildings", action: #selector(buildingsButtonPressed))
        let poisButton = addLayerButton(title: "POIs", action: #selector(poisButtonPressed))
        let weatherButton = addLayerButton(title: "Weather", action: #selector(weatherButtonPressed))

        NSLayoutConstraint.activate([
            weatherButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -10),
            weatherButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            weatherButton.leadingAnchor.constraint(equalTo: buildingsButton.leadingAnchor, constant: 0),
            poisButton.bottomAnchor.constraint(equalTo: weatherButton.topAnchor, constant: -5),
            poisButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            poisButton.leadingAnchor.constraint(equalTo: buildingsButton.leadingAnchor, constant: 0),
            buildingsButton.bottomAnchor.constraint(equalTo: poisButton.topAnchor, constant: -5),
            buildingsButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            buildingsButton.leadingAnchor.constraint(equalTo: buildingsButton.leadingAnchor, constant: 0),
            trafficButton.bottomAnchor.constraint(equalTo: buildingsButton.topAnchor, constant: -5),
            trafficButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            trafficButton.leadingAnchor.constraint(equalTo: buildingsButton.leadingAnchor, constant: 0),
        ])

    }

    @objc func trafficButtonPressed() {
        mapView.style?.toggleTrafficVisibility()
    }

    @objc func buildingsButtonPressed() {
        mapView.style?.toggle3dBuildingVisibility()
    }

    @objc func poisButtonPressed() {
        mapView.style?.togglePoiVisibility()
    }

    @objc func weatherButtonPressed() {
        mapView.style?.toggleWeatherAlertVisibility()
    }
}

