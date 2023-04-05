//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    private let storageManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        storageManager.fetchData(completion: {[unowned self] result in
            switch result {
            case .success(let tasks):
                taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, task: Task? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            guard let task = task else {
                self?.save(taskName)
                return
            }
            self?.update(task, with: taskName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = task?.title
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task = storageManager.saveTask(taskName)
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func update(_ task: Task, with name: String) {
        guard let taskIndex = taskList.firstIndex(of: task) else { return }
        
        storageManager.updateTask(task, with: name)
        
        let indexPath = IndexPath(row: taskIndex, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlert(
            withTitle: "Update task",
            andMessage: "What do you want to do?",
            task: taskList[indexPath.row]
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToRemove = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            storageManager.delete(task: taskToRemove)
        }
    }
}
