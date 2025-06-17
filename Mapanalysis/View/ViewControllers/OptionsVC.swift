//
//  OptionsVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class OptionsVC: UITableViewController {
	
	@IBOutlet weak var continiousLocationUpdateSwitch: UISwitch!
	@IBOutlet weak var mapZoomSlider: UISlider!
	@IBOutlet weak var mapTypeSegment: UISegmentedControl!
	
	var continuousUpdates: ((Bool) -> Void)?
	var mapUpdate: (() -> Void)?
	var locationUpdate: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	func setupUI() {
		sheetPresentationController?.prefersGrabberVisible = true
		sheetPresentationController?.largestUndimmedDetentIdentifier = .none
		sheetPresentationController?.detents = [ .large() ]
		
		continiousLocationUpdateSwitch.isOn = AppPreferences.shared.continuousUpdates
		mapZoomSlider.value = Float(AppPreferences.shared.mapZoom)
		mapTypeSegment.selectedSegmentIndex = AppPreferences.shared.mapType.rawValue
	}
	
	//MARK: - IBActions
	
	@IBAction func setContinuousUpdating() {
		AppPreferences.shared.continuousUpdates = continiousLocationUpdateSwitch.isOn
		continuousUpdates?(continiousLocationUpdateSwitch.isOn)
	}
	
	@IBAction func setMapZoomLevel() {
		AppPreferences.shared.mapZoom = Double(mapZoomSlider.value)
		locationUpdate?()
	}
	
	@IBAction func setMapType() {
		AppPreferences.shared.mapType = MapType(rawValue: mapTypeSegment.selectedSegmentIndex)!
		mapUpdate?()
	}
	
	//MARK: - TableView
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
