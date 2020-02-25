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
    
    private var timeInterval: TimeInterval! = Date().timeIntervalSinceNow + 60
    weak private var delegate: CreateTimerControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func createLocalNotification() {
        let content = UNMutableNotificationContent()
        guard let timerTitle = timerDescriptionField.text, !timerTitle.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title in the required text field.")
            return
        }
        content.title = timerTitle
        let dateString = reformatDate(timeInterval)
        content.body = "Set to go off at \(dateString)."
        content.subtitle = "Your \(dateString) timer has gone off."
        content.sound = .default
        
        let identifier = UUID().uuidString
        if let imageURL = Bundle.main.url(forResource: "alarmclock", withExtension: "jpg") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                showAlert(title: "Error", message: "Couldn't set attachment: \(error)")
            }
        } else {
            showAlert(title: "Error", message: "Image could not be found")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error adding request: \(error)")
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Success", message: "Timer was successfully added.")
                }
            }
        }
    }
    
    func reformatDate(_ input: TimeInterval) -> String {
        let tempDate = Date(timeIntervalSinceNow: input)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: tempDate)
        return dateString
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
