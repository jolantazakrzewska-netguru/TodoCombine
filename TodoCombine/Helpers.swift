//
//  Helpers.swift
//  TodoCombine
//
//  Created by Jolanta Zakrzewska on 28/07/2021.
//

import Combine
import Foundation

// MARK: - Necessary extensions

extension Publisher {

  /// When `Self` emits, it will emit a value of the latest from `Other`.
  public func withLatestFrom<Other: Publisher, Result>(
    _ other: Other,
    resultSelector: @escaping (Output, Other.Output) -> Result
  ) -> AnyPublisher<Result, Failure> where Self.Failure == Other.Failure {
    map { (arc4random(), $0) } // assign unique id to the Self publisher's events
      .combineLatest(other) // pair with the Other publisher's events
      // the combined event: ((arc4random, self), other)
      .removeDuplicates { $0.0.0 == $1.0.0 } // remove duplicates of the Self publisher's events
      // this causes to pass the other publisher's events only when
      // the new event in the Self publisher appears
      .map { ($0.1, $1) } // remove unique id, map to the expected output
      .map(resultSelector) // trigger the final publisher
      .eraseToAnyPublisher()
  }

  public func withLatestFrom<Other: Publisher>(_ other: Other) -> AnyPublisher<Other.Output, Failure>
    where Self.Failure == Other.Failure
  {
    withLatestFrom(other) { $1 }
  }
}

// MARK: - Helpful extensions

extension Publisher {

  /// Skips emitted values of any kind.
  public func ignoreValues() -> AnyPublisher<Void, Failure> {
    map { _ in }
      .eraseToAnyPublisher()
  }
}

extension Publisher where Failure == Never {
  /// Overrides`assign(to:on:)` to weakly retain `root`.
  ///
  /// This ensures assigning to a property on `self` while storing in a child
  /// `AnyCancellable` will still allow for deallocations. https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546/11
  public func assign<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>,
    on root: Root
  ) -> AnyCancellable {
    sink { [weak root] in
      root?[keyPath: keyPath] = $0
    }
  }

  public func assign<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output?>,
    on object: Root
  ) -> AnyCancellable {
    map(Output?.some)
      .assign(to: keyPath, on: object)
  }

  public func assignOnMain<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>,
    on object: Root
  ) -> AnyCancellable {
    receive(on: DispatchQueue.main)
      .assign(to: keyPath, on: object)
  }

  public func assignOnMain<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output?>,
    on object: Root
  ) -> AnyCancellable {
    receive(on: DispatchQueue.main)
      .assign(to: keyPath, on: object)
  }

  public func sinkOnMain(_ receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
    receive(on: DispatchQueue.main)
      .sink(receiveValue: receiveValue)
  }
}
