//
//  String+Extension.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 26/6/25.
//

import Foundation

extension String {
	static func filename(file: String = #file) -> String {
		return file.components(separatedBy: "/").last ?? URL(fileURLWithPath: file).lastPathComponent
	}
	
	static func className(file: String = #file) -> String {
		let file = filename(file: file)
		return (file as NSString).deletingPathExtension
	}

	static func debugInfo(file: String = #file, function: String = #function, line: Int = #line) -> String {
		let className = className(file: file)
		return "[\(className):\(function)@\(line)] "
	}
}
