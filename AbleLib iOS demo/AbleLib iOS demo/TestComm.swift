//
//  TestComm.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 04/11/2020.
//

import Foundation
import Able

let GAME_SERVICE = AbleUUID(with: "7c2a9688-43ba-4254-83ad-cc9df6deb72b")
let GAME_PARTY_CHARACTERISTICS = AbleUUID(with: "e4eada67-6da6-4bdd-841a-1489a633cd1f")
let GAME_BOARD_CHARACTERISTICS = AbleUUID(with: "b5609b14-8a0c-4778-b46f-535772230bfd")
let CLIENT_CONFIG = AbleUUID(with: "4a134627-a123-410e-b5d2-08c30219c52f")

typealias Logger = (String) -> Void

class TestComm {
    private let comm: AbleComm
    
    init(comm: AbleComm) {
        self.comm = comm
    }
    
    func start(_ logger: @escaping Logger) {
        comm.discoverServices([GAME_SERVICE]) { result in
            self.handleResult(logger: logger, result: result) { services in
                logger("Found game service")
                if let service = services.first {
//                    self.testPartyCharacteristics(logger: logger, service: service)
                    self.testBoardCharacteristics(logger: logger, service: service)
                }
            }
        }
    }
    
    private func testPartyCharacteristics(logger: @escaping Logger, service: AbleService) {
        self.comm.discoverCharacteristics([GAME_PARTY_CHARACTERISTICS], for: service) { result in
            self.handleResult(logger: logger, result: result) { chars in
                logger("Found game party characteristic")
                if let char = chars.first {
                    self.comm.discoverDescriptors(for: char) { result in
                        self.handleResult(logger: logger, result: result) { descs in
                                logger("Found client config descriptor")
                            self.comm.writeDescriptor(descs.first!, data: Data()) { result in
                                logger("Write descriptor result\(result)")
                            }
                            self.comm.setNotifyValue(false, for: char) { result in
                                self.handleResult(logger: logger, result: result) { char in
                                    print("Notify completion: \(String(describing: char.value))")
                                }
                            } onValueUpdated: { result in
                                self.handleResult(logger: logger, result: result) { (char) in
                                    print("Notify value update: \(String(describing: char.value))")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func testBoardCharacteristics(logger: @escaping Logger, service: AbleService) {
        comm.discoverCharacteristics([GAME_BOARD_CHARACTERISTICS], for: service) { result in
            self.handleResult(logger: logger, result: result) { chars in
                logger("Found game board characteristic")
                
                if let char = chars.first {
                    self.comm.writeCharacteristic(char, data: "xoxoxoxo".data(using: .utf8)!, type: .withResponse) { result in
                        self.handleResult(logger: logger, result: result) { success in
                            print("Write success: \(success)")
                        }
                    }
                    self.comm.setNotifyValue(false, for: char) { result in
                        self.handleResult(logger: logger, result: result) { char in
                            print("Notify completion: \(String(describing: char.value))")
                        }
                    } onValueUpdated: { result in
                        self.handleResult(logger: logger, result: result) { (char) in
                            print("Notify value update: \(String(describing: char.value))")
                        }
                    }
                }
            }
        }
    }
    
    private func handleResult<Success, Failure>(logger: @escaping Logger,
                                                result: Result<Success, Failure>,
                                                onSuccess: @escaping (Success) -> Void) {
        result.onFailure { error in
            logger(error.localizedDescription)
        }.onSuccess(onSuccess)
    }
}
