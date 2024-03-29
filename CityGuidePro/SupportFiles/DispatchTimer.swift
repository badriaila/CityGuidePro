//
//  DispatchTimer.swift
//  CityGuide
//
//  Updated by AJ
//

import UIKit

///
/// DispatchTimer
///
/// Much like an NSTimer from Cocoa, but implemented using dispatch queues instead.
///
class DispatchTimer: NSObject {

  /// Type for the handler block executed when a dispatch timer fires.
  ///
  /// :param: timer The timer which triggered this block
  typealias TimerHandler = (DispatchTimer) -> Void

  private let timerBlock: TimerHandler
  private let queue: DispatchQueue
  private let delay: TimeInterval

  private var wrappedBlock: (() -> Void)?
  private let source: DispatchSourceTimer

  init(delay: TimeInterval, queue: DispatchQueue, block: @escaping TimerHandler) {
    timerBlock = block
    self.queue = queue
    self.delay = delay
    self.source = DispatchSource.makeTimerSource(queue: queue)

    super.init()

    let wrapper = { () -> Void in
       if !self.source.isCancelled {
        self.source.cancel()
        self.timerBlock(self)
      }
    }

    self.wrappedBlock = wrapper
  }

  class func scheduledDispatchTimer(delay: TimeInterval, queue: DispatchQueue, block: @escaping TimerHandler) -> DispatchTimer {
    let dt = DispatchTimer(delay: delay, queue: queue, block: block)
    dt.schedule()
    
    return dt
  }

  func schedule() {
    self.reschedule()
    self.source.setEventHandler(handler: self.wrappedBlock)
    self.source.resume()
  }

  func reschedule() {
    self.source.schedule(deadline: .now() + self.delay)
  }

  func suspend() {
    self.source.suspend()
  }

  func resume() {
    self.source.resume()
  }

  func cancel() {
    self.source.cancel()
  }

}
