//
//  OptionsVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class OptionsVC: UITableViewController {
	
	@IBOutlet weak var continuousSwitch: UISwitch!
	@IBOutlet weak var backgroundSwitch: UISwitch!
	@IBOutlet weak var mapZoomSlider: UISlider!
	@IBOutlet weak var mapTypeSegment: UISegmentedControl!
	
	var continuousUpdates: ((Bool) -> Void)?
	var backgroundUpdates: ((Bool) -> Void)?
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
		
		continuousSwitch.isOn = AppPreferences.shared.continuousUpdates
		backgroundSwitch.isOn = AppPreferences.shared.backgroundUpdates
		backgroundSwitch.isEnabled = continuousSwitch.isOn
		mapZoomSlider.value = Float(AppPreferences.shared.mapZoom)
		mapTypeSegment.selectedSegmentIndex = AppPreferences.shared.mapType.rawValue
	}
	
	//MARK: - IBActions
	
	@IBAction func continuousUpdatesAction(_ sender: UISwitch) {
		AppPreferences.shared.continuousUpdates = sender.isOn
		backgroundSwitch.isEnabled = sender.isOn
		continuousUpdates?(sender.isOn)
	}
	
	@IBAction func backgroundUpdatesAction(_ sender: UISwitch) {
		AppPreferences.shared.backgroundUpdates = sender.isOn
		backgroundUpdates?(sender.isOn)
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
