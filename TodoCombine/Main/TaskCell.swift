//
//  TaskCell.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 28/07/2021.
//

import Combine
import SnapKit
import UIKit

final class TaskCell: UITableViewCell {
  typealias Value = (
    Task,
    removeSubject: PassthroughSubject<Task, Never>
  )

  private let mainLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .regular)
    return label
  }()

  private var cancellables = Set<AnyCancellable>()
  private let taskSubject = PassthroughSubject<Task, Never>()
  private weak var removeSubject: PassthroughSubject<Task, Never>?
  private let tapGesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.numberOfTapsRequired = 2
    return gesture
  }()

  func set(with value: Value) {
    let (task, removeSubject) = value
    self.removeSubject = removeSubject
    taskSubject.send(task)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()

    let (
      mainLabelText,
      sendRemoveTask
    ) = taskCellViewModel(
      removeAction: tapGesture.tapPublisher
        .map { _ in }
        .eraseToAnyPublisher(),
      task: taskSubject.eraseToAnyPublisher()
    )

    mainLabelText
      .receive(on: DispatchQueue.main)
      .assign(to: \.text, on: mainLabel)
      .store(in: &cancellables)

    sendRemoveTask
      .receive(on: DispatchQueue.main)
      .sink { [weak self] task in
        self?.removeSubject?.send(task)
      }
      .store(in: &cancellables)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    mainLabel.text = nil
  }
}

private extension TaskCell {
  func setupView() {
    addSubview(mainLabel)
    addGestureRecognizer(tapGesture)

    mainLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
