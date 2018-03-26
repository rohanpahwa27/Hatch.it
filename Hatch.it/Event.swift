//
//  Event.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class Event: NSObject {
    var codedDate: String?
    var eventVisibility: String?
    var eventDate: String?
    var eventDescription: String?
    var eventName: String?
    var startTime: String?
    var endTime: String?
    var eventAddress: String?
    var eventType: String?
    var lat: Double?
    var long: Double?
    var numOfHead: String?
    var location: String?
    var whatToBring: String?
    var distance = 0.0
    var eventImage: String?
    var uuid: String?
    var host: String?
    var interestedUsers = [String]()
    var usersGoing = [String]()
    var requestedUsers = [String]()
    var score = 0
    var interested = false
    var price: String?
}
