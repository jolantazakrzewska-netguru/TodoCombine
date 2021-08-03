//
//  TasksViewModel.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 28/07/2021.
//

import Combine
import UIKit.UIImage

func tasksViewModel(
  addButtonTapped: AnyPublisher<Void, Never>,
  data: AnyPublisher<[Task], Never>,
  removeAction: AnyPublisher<Task, Never>,
  textInput: AnyPublisher<String, Never>
) -> (
  addButtonImage: AnyPublisher<UIImage?, Never>,
  addTask: AnyPublisher<Task, Never>,
  clearInput: AnyPublisher<Void, Never>,
  headerText: AnyPublisher<String?, Never>,
  refreshData: AnyPublisher<[Task], Never>
) {
  let addButtonImage = Just(
    UIImage(
      systemName: "plus",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
    )
  )
  .eraseToAnyPublisher()

  let addTask = addButtonTapped
    .withLatestFrom(textInput)
    .filter { !$0.isEmpty }
    .map { Task(text: $0) }
    .eraseToAnyPublisher()

  let clearInput = addTask
    .map { _ in }
    .eraseToAnyPublisher()

  let headerText = Just(
    Optional("Todo with Combine")
  )
  .eraseToAnyPublisher()

  let refreshData = removeAction
    .withLatestFrom(data) { (taskToRemove: $0, currentTasks: $1) }
    .handleEvents(receiveOutput: { output in
      print("[TEST] before filtering output: \(output)")
    })
    .map { taskToRemove, currentTasks in
      currentTasks.filter { task in
        task.id != taskToRemove.id
      }
    }
    .handleEvents(receiveOutput: { output in
      print("[TEST] after filtering output: \(output)")
    })
    .eraseToAnyPublisher()

  return (
    addButtonImage: addButtonImage,
    addTask: addTask,
    clearInput: clearInput,
    headerText: headerText,
    refreshData: refreshData
  )
}
