//
//  ViewController.swift
//  HW(Core Data)3.6
//
//  Created by Иса on 06.12.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
}

//MARK: Update TaskListViewController
extension TaskListViewController {
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationAppereance = UINavigationBarAppearance()
        navigationAppereance.configureWithOpaqueBackground()
        
        navigationAppereance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationAppereance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationAppereance.backgroundColor = UIColor(red: 21/255,
                                                       green: 102/255,
                                                       blue: 192/255,
                                                       alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navigationAppereance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationAppereance
        
        let newTaskButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTappedButton)
        )
        navigationItem.rightBarButtonItem = newTaskButton
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTappedButton() {
        showAlert(with: "New task", message: "Add new task")
    }
    
    private func showAlert(with title: String, message: String, index: Int? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            if let index = index {
                self?.update(text, index: index)
            } else {
                self?.save(text)
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField { [weak self] textField in
            if let index = index {
                textField.text = self?.taskList[index].title
            } else {
                textField.placeholder = "New Task"
            }
        }
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
}

// MARK: Extension methods for StorageManager
extension TaskListViewController {
    
    private func fetchData() {
        StorageManager.shared.fetch { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
            case .failure(let error):
                print("Failed to fetch data", error)
            }
        }
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName) { [weak self] result in
            switch result {
            case .success(let task):
                self?.taskList.append(task)
                let cellIndex = IndexPath(row: (self?.taskList.count ?? 0) - 1, section: 0)
                self?.tableView.insertRows(at: [cellIndex], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func update(_ taskName: String, index: Int) {
        StorageManager.shared.update(with: taskList[index], newName: taskName)
        tableView.reloadData()
    }
    
    private func deleteTask(with task: Task) {
        StorageManager.shared.delete(with: task)
    }
}

// MARK: Extension TableView
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
        showAlert(with: "Edit Task", message: "Editing task", index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(with: taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

