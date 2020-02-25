//
//  ViewController.swift
//  Location-Notification-Lab
//
//  Created by Matthew Ramos on 2/20/20.
//  Copyright © 2020 Matthew Ramos. All rights reserved.
//

import UIKit

class TimerListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var timers = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForNotificationAuthorization()
        loadNotifications()
        tableView.dataSource = self
        nCenter.delegate = self
        configureRefreshControl()
    }
    
    private let nCenter = UNUserNotificationCenter.current()
    private let pendingNotification = PendingNotification()
    private var refreshControl: UIRefreshControl!
    
    private func configureRefreshControl() {
            refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
        }
    
        @objc private func loadNotifications() {
            pendingNotification.getPendingNotifications { (requests) in
                self.timers = requests
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    
    private func removeNotification(atIndexPath indexPath: IndexPath) {
        let timer = timers[indexPath.row]
        let identifier = timer.identifier
        nCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        timers.remove(at: indexPath.row)
    }
        
        private func checkForNotificationAuthorization() {
            nCenter.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    self.requestNotificationPermissions()
                }
            }
        }
        
        private func requestNotificationPermissions() {
            nCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Error with authorization: \(error)")
                    }
                    return
                }
                if granted {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Accepted", message: "Notification permission has been granted.")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Failure", message: "Notifiction permission has been denied.")
                    }
                }
            }
        }
    }

extension TimerListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath)
        let timer = timers[indexPath.row]
        cell.textLabel?.text = timer.content.title
        cell.detailTextLabel?.text = timer.content.body
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNotification(atIndexPath: indexPath)
        }
    }
}

extension TimerListViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension TimerListViewController: CreateTimerControllerDelegate {
    func didCreateTimer(_ createTimerViewController: CreateTimerViewController) {
        loadNotifications()
    }
}
