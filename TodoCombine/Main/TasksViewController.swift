//
//  TasksViewController.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 28/07/2021.
//

import Combine
import CombineCocoa
import UIKit

class TasksViewController: UIViewController {

  private lazy var tasksView: TasksView = {
    let view = TasksView()
    view.taskTable.dataSource = self
    view.taskTextView.delegate = self
    return view
  }()

  private var tasks: [Task] = []
  private let tasksSubject = PassthroughSubject<[Task], Never>()
  private let taskInputSubject = PassthroughSubject<String, Never>()
  private let removeActionSubject = PassthroughSubject<Task, Never>()
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    tasksSubject.send(tasks)

    let (
      addButtonImage,
      addTask,
      clearInput,
      headerText,
      refreshData
    ) = tasksViewModel(
      addButtonTapped: tasksView.addButton.tapPublisher,
      data: tasksSubject.eraseToAnyPublisher(),
      removeAction: removeActionSubject.eraseToAnyPublisher(),
      textInput: taskInputSubject.eraseToAnyPublisher()
    )

    addButtonImage
      .receive(on: DispatchQueue.main)
      .sink { [weak self] image in
        self?.tasksView.addButton.setImage(image, for: .normal)
      }
      .store(in: &cancellables)

    addTask
      .receive(on: DispatchQueue.main)
      .sink { [weak self] task in
        guard let self = self else { return }
        self.tasks.append(task)
        self.tasksSubject.send(self.tasks)
        self.tasksView.taskTable.reloadData()
      }
      .store(in: &cancellables)

    clearInput
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.tasksView.taskTextView.text = ""
        self?.taskInputSubject.send("")
      }
      .store(in: &cancellables)

    headerText
      .receive(on: DispatchQueue.main)
      .assign(to: \.text, on: tasksView.header)
      .store(in: &cancellables)

    refreshData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] tasks in
        guard let self = self else { return }
        self.tasks = tasks
        self.tasksSubject.send(self.tasks)
        self.tasksView.taskTable.reloadData()
      }
      .store(in: &cancellables)
  }

  override func loadView() {
    view = tasksView
  }
}

extension TasksViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tasks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell
    else { return UITableViewCell() }

    let task = tasks[indexPath.row]
    cell.set(with: (
      task,
      removeSubject: removeActionSubject
    ))
    return cell
  }
}

extension TasksViewController: UITextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String
  ) -> Bool {
    textView.text.count + (text.count - range.length) <= 30
  }

  func textViewDidChange(_ textView: UITextView) {
    taskInputSubject.send(textView.text ?? "")
  }
}
