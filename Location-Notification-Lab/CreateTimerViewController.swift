//
//  CreateTimerViewController.swift
//  Location-Notification-Lab
//
//  Created by Matthew Ramos on 2/20/20.
//  Copyright © 2020 Matthew Ramos. All rights reserved.
//

import UIKit

protocol CreateTimerControllerDelegate: AnyObject {
    func didCreateTimer(_ createTimerViewController: CreateTimerViewController)
}

class CreateTimerViewController: UIViewController {
    
    @IBOutlet weak var timerDescriptionField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var timeInterval: TimeInterval! = Date().timeIntervalSinceNow + 2
    weak private var delegate: CreateTimerControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func createLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = timerDescriptionField.text ?? "Title"
        content.body = "You have a \(datePicker.date.description) timer"
        content.subtitle = "Set to go off in \(timeInterval.description)"
        content.sound = .default
        
        let identifier = UUID().uuidString
        if let imageURL = Bundle.main.url(forResource: "alarmclock", withExtension: "jpg") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
//                showAlert(title: "Error", message: "Couldn't set attachment: \(error)")
            }
        } else {
//            showAlert(title: "Error", message: "Image could not be found")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error adding request: \(error)")
            } else {
                print("request was successfully added")
            }
        }
        
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        timeInterval = sender.countDownDuration
    }
    
    @IBAction func setTimerPressed(_ sender: UIButton) {
        createLocalNotification()
        delegate?.didCreateTimer(self)
        dismiss(animated: true)
    }
}
