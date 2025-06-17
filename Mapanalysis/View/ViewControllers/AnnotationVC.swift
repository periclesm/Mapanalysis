//
//  AnnotationVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class AnnotationVC: UIViewController {
	
	var annotation: Annotation?
	
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var adminLabel: UILabel!
	@IBOutlet weak var countryLabel: UILabel!
	@IBOutlet weak var latLabel: UILabel!
	@IBOutlet weak var lonLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	func setupUI() {
		sheetPresentationController?.prefersGrabberVisible = true
		sheetPresentationController?.largestUndimmedDetentIdentifier = .none
		sheetPresentationController?.detents = [ .medium(), ]
		
		addressLabel.text = annotation?.address?.address?.isEmpty ?? true ? annotation?.address?.name : annotation?.address?.address
		cityLabel.text = "\(annotation?.address?.postalCode ?? "") \(annotation?.address?.locality ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
		adminLabel.text = "\(annotation?.address?.administrative ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
		countryLabel.text = "\(annotation?.address?.country ?? "")"
		
		latLabel.text = annotation?.latitudeText
		lonLabel.text = annotation?.longtitudeText
		
		setButtonTitle()
	}
	
	//MARK: - IBActions
	
	@IBAction func favoriteAction() {
		guard let annotation else { return }
		
		if AppPreferences.shared.favorites.contains(annotation) {
			removeFavorite()
		} else {
			addFavorite()
		}
		
		setButtonTitle()
	}
	
	private func addFavorite() {
		guard let annotation else { return }
		
		AppPreferences.shared.favorites.append(annotation)
	}
	
	private func removeFavorite() {
		guard let annotation else { return }
		
		if let index = AppPreferences.shared.favorites.firstIndex(of: annotation) {
			AppPreferences.shared.favorites.remove(at: index)
		}
	}
	
	private func setButtonTitle() {
		guard let annotation else { return }
		
		if AppPreferences.shared.favorites.contains(annotation) {
			favoriteButton.setTitle("Remove Favorite", for: .normal)
		} else {
			favoriteButton.setTitle("Add Favorite", for: .normal)
		}
	}
}
