//
//  MALocationButton.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit

class MALocationButton: UIButton {

    enum LocationState {
        case standard, continuousOFF, continuousON
    }
    
    /*
	 Continuous Location: Filled Location Icon with SystemTeal when On and SystemPurple when Off
     Non-Continuous: Outlined Location Icon with SystemPurple Background
     */
    
    func setState(state: LocationState) {
        switch state {
        case .standard: 
            self.tintColor = .systemPurple
            self.setImage(UIImage(systemName: "location"), for: .normal)
        
        case .continuousOFF: 
            self.tintColor = .systemPurple
            self.setImage(UIImage(systemName: "location.fill"), for: .normal)
            
        case .continuousON: 
            self.tintColor = .systemPink
            self.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
}
