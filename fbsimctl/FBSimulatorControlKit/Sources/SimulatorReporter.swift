/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation
import FBSimulatorControl

open class SimulatorReporter : NSObject, FBSimulatorEventSink, iOSReporter {
  unowned open let simulator: FBSimulator
  open let reporter: EventReporter
  open let format: FBiOSTargetFormat

  init(simulator: FBSimulator, format: FBiOSTargetFormat, reporter: EventReporter) {
    self.simulator = simulator
    self.reporter = reporter
    self.format = format
    super.init()
    simulator.userEventSink = self
  }

  open var target: FBiOSTarget { get {
    return self.simulator
  }}

  open func containerApplicationDidLaunch(_ applicationProcess: FBProcessInfo) {
    self.reportValue(.launch, .discrete, applicationProcess)
  }

  open func containerApplicationDidTerminate(_ applicationProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(.terminate, .discrete, applicationProcess)
  }

  open func connectionDidConnect(_ connection: FBSimulatorConnection) {
    self.reportValue(.launch, .discrete, connection)
  }

  open func connectionDidDisconnect(_ connection: FBSimulatorConnection, expected: Bool) {
    self.reportValue(.terminate, .discrete, connection)
  }

  open func testmanagerDidConnect(_ testManager: FBTestManager) {

  }

  open func testmanagerDidDisconnect(_ testManager: FBTestManager) {

  }

  open func simulatorDidLaunch(_ launchdProcess: FBProcessInfo) {
    self.reportValue(.launch, .discrete, launchdProcess)
  }

  open func simulatorDidTerminate(_ launchdProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(.terminate, .discrete, launchdProcess)
  }

  open func agentDidLaunch(_ operation: FBSimulatorAgentOperation) {
    self.reportValue(.launch, .discrete, operation.process)
  }

  open func agentDidTerminate(_ operation: FBSimulatorAgentOperation, statLoc: Int32) {
    self.reportValue(.terminate, .discrete, operation.process)
  }

  public func applicationDidLaunch(_ operation: FBSimulatorApplicationOperation) {
    self.reportValue(.launch, .discrete, operation.process)
    if operation.configuration.waitForDebugger {
      self.reporter.logInfo("Application launched. To debug, run lldb -p \(operation.process.processIdentifier).")
    }
  }

  open func applicationDidTerminate(_ operation: FBSimulatorApplicationOperation, expected: Bool) {
    self.reportValue(.terminate, .discrete, operation.process)
  }

  open func diagnosticAvailable(_ log: FBDiagnostic) {
    self.reportValue(.diagnostic, .discrete, log)
  }

  open func didChange(_ state: FBSimulatorState) {
    self.reportValue(.stateChange, .discrete, FBEventReporterSubject(string: state.description))
  }

  open func terminationHandleAvailable(_ terminationHandle: FBTerminationHandle) {

  }
}
