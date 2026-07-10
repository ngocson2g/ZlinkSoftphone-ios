import Foundation
import linphonesw

func test() {
    let core = try! Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
    let friend = try! core.createFriend()
    if let vcard = friend.vcard {
        vcard.note = "test note"
    }
}
