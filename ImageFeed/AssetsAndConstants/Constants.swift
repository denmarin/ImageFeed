//
//  Constants.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 25.10.25.
//

import Foundation

nonisolated enum Constants {
    public static let accessKey = "0AFUCt3eiA-KgxWWymbCKHuXrBHz9ekf0qVytN75sqU"
    public static let secretKey = "97reZ7soU27DzlttbsBahlFnZ4gNxTXlIR7LdW472KU"
    public static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    public static let accessScope = "public+read_user+write_likes"
    public static let defaultBaseURL = URL(string: "https://api.unsplash.com")
	public static let GetMeURL = URL(string: "https://api.unsplash.com/me")
	public static let GetUserURL = URL(string: "https://api.unsplash.com/users/")
}

