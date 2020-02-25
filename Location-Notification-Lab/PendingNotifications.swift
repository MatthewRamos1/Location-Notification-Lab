//
//  PendingNotifications.swift
//  Location-Notification-Lab
//
//  Created by Matthew Ramos on 2/24/20.
//  Copyright © 2020 Matthew Ramos. All rights reserved.
//

import Foundation
import UserNotifications

class PendingNotification {
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> ()) { UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            completion(requests)
        }
    }
}
