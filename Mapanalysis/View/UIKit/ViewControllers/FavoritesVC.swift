//
//  FavoritesVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class FavoritesVC: UITableViewController {
	
	@IBOutlet weak var backgroundView: UIView!
		
	var presentAnnotation: ((Annotation) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	func setupUI() {
		self.tableView.backgroundView = backgroundView
		sheetPresentationController?.prefersGrabberVisible = true
		sheetPresentationController?.largestUndimmedDetentIdentifier = .none
		sheetPresentationController?.detents = [ .medium(), .large() ]
	}

    // MARK: - Table view
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if AppPreferences.shared.favorites.isEmpty {
			self.backgroundView.isHidden = false
		} else {
			self.backgroundView.isHidden = true
		}

		return AppPreferences.shared.favorites.count
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if AppPreferences.shared.favorites.isNotEmpty {
			return "Saved Locations"
		} else {
			return ""
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
		let annotation = AppPreferences.shared.favorites[indexPath.row]
		cell.titleLabel.text = annotation.title
		cell.latitudeLabel.text = annotation.latitudeText
		cell.longitudeLabel.text = annotation.longtitudeText

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let annotation = AppPreferences.shared.favorites[indexPath.row]
		dismiss(animated: true) {
			self.presentAnnotation?(annotation)
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action, sourceView, completionHandler) in
			AppPreferences.shared.favorites.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	
		deleteAction.backgroundColor = .systemRed
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

class FavoriteCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
}
