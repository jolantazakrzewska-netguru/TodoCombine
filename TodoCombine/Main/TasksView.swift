//
//  TasksView.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 28/07/2021.
//

import UIKit
import SnapKit

final class TasksView: UIView {

  let header: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()

  let taskTextView: UITextView = {
    let textView = UITextView()
    textView.textContainer.maximumNumberOfLines = 1
    textView.textContainer.lineBreakMode = .byTruncatingTail
    textView.isScrollEnabled = false
    return textView
  }()

  let addButton = UIButton()

  let taskTable: UITableView = {
    let tableView = UITableView()
    tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 40
    tableView.allowsSelection = false
    return tableView
  }()

  private let taskInputView = UIView()

  init() {
    super.init(frame: .zero)
    backgroundColor = .white
    addSubview(header)
    addSubview(taskTable)
    addSubview(taskInputView)
    taskInputView.addSubview(taskTextView)
    taskInputView.addSubview(addButton)

    header.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Inset.margin)
      $0.left.equalToSuperview().offset(Inset.margin)
      $0.right.equalToSuperview().offset(-Inset.margin)
    }

    taskTable.snp.makeConstraints {
      $0.top.equalTo(header.snp.bottom).offset(Inset.spacing)
      $0.left.equalToSuperview().offset(Inset.margin)
      $0.right.equalToSuperview().offset(-Inset.margin)
    }

    taskInputView.snp.makeConstraints {
      $0.top.equalTo(taskTable.snp.bottom).offset(Inset.spacing)
      $0.left.equalToSuperview().offset(Inset.margin)
      $0.right.bottom.equalToSuperview().offset(-Inset.margin)
      $0.height.equalTo(Size.inputView)
    }

    taskTextView.snp.makeConstraints {
      $0.top.left.bottom.equalToSuperview()
    }

    addButton.snp.makeConstraints {
      $0.left.equalTo(taskTextView.snp.right).offset(Inset.spacing)
      $0.top.right.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension TasksView {

  enum Inset {

    static let margin: CGFloat = 16
    static let spacing: CGFloat = 8
  }

  enum Size {

    static let inputView: CGFloat = 40
  }
}
