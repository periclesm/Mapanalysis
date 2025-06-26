//
//  OptionsVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class OptionsVC: UITableViewController {
	
	@IBOutlet weak var centerSwitch: UISwitch!
	@IBOutlet weak var headingSwitch: UISwitch!
	@IBOutlet weak var mapZoomSlider: UISlider!
	@IBOutlet weak var mapTypeSegment: UISegmentedControl!
	
	var centerMap: ((Bool) -> Void)?
	var headingOnMap: ((Bool) -> Void)?
	var setMapType: (() -> Void)?
	var setMapZoomLevel: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			case "UnavailableSegue":
				let dvc = segue.destination
				dvc.sheetPresentationController?.prefersGrabberVisible = true
				
			default : break
		}
	}
	
	func setupUI() {
		sheetPresentationController?.prefersGrabberVisible = true
		sheetPresentationController?.largestUndimmedDetentIdentifier = .none
		sheetPresentationController?.detents = [ .medium(), .large() ]
		
		centerSwitch.isOn = AppPreferences.shared.centerMap
		headingSwitch.isOn = AppPreferences.shared.headingOnMap
		headingSwitch.isEnabled = centerSwitch.isOn
		mapZoomSlider.value = Float(AppPreferences.shared.mapZoom)
		mapTypeSegment.selectedSegmentIndex = AppPreferences.shared.mapType.rawValue
	}
	
	//MARK: - IBActions
	
	@IBAction func centerMapAction(_ sender: UISwitch) {
		AppPreferences.shared.centerMap = sender.isOn
		headingSwitch.isEnabled = sender.isOn
		centerMap?(sender.isOn)
	}
	
	@IBAction func headingOnMapAction(_ sender: UISwitch) {
		AppPreferences.shared.headingOnMap = sender.isOn
		headingOnMap?(sender.isOn)
	}
	
	@IBAction func mapZoomLevelAction(_ sender: UISlider) {
		AppPreferences.shared.mapZoom = Double(sender.value)
		setMapZoomLevel?()
	}
	
	@IBAction func mapTypeAction(_ sender: UISegmentedControl) {
		AppPreferences.shared.mapType = MapType(rawValue: sender.selectedSegmentIndex)!
		setMapType?()
	}
	
	//MARK: - TableView
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
