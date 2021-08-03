//
//  TaskCellViewModel.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 30/07/2021.
//

import Combine
import UIKit.UIImage

func taskCellViewModel(
  removeAction: AnyPublisher<Void, Never>,
  task: AnyPublisher<Task, Never>
) -> (
  mainLabelText: AnyPublisher<String?, Never>,
  sendRemoveTask: AnyPublisher<Task, Never>
) {
  let mainLabelText = task
    .map { Optional($0.text) }
    .eraseToAnyPublisher()

  let sendRemoveTask = removeAction
    .withLatestFrom(task)
    .eraseToAnyPublisher()

  return (
    mainLabelText: mainLabelText,
    sendRemoveTask: sendRemoveTask
  )
}
