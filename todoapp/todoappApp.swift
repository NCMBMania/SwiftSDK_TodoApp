//
//  todoappApp.swift
//  todoapp
//
//  Created by Atsushi on 2021/04/05.
//

import SwiftUI
import NCMB

@main
struct todoappApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { scene in
            switch scene {
            case .active:
                NCMB.initialize(applicationKey: "9170ffcb91da1bbe0eff808a967e12ce081ae9e3262ad3e5c3cac0d9e54ad941", clientKey: "9e5014cd2d76a73b4596deffdc6ec4028cfc1373529325f8e71b7a6ed553157d")
                NCMBUser.enableAutomaticUser()
                let user = NCMBUser.currentUser
                if user == nil {
                    NCMBUser.automaticCurrentUserInBackground(callback: { result in
                        switch result {
                                case .success:
                                    // ログインに成功した場合の処理
                                    print("匿名ユーザーでのログインに成功しました")
                                case let .failure(error):
                                    // ログインに失敗した場合の処理
                                    print("匿名ユーザーでのログインに失敗しました: \(error)")
                            }
                    })
                } else {
                    // セッションの有効性チェック
                    var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "Todo")
                    query.limit = 1
                    query.findInBackground(callback: { results in
                        switch results {
                        case let .success(obj):
                            print(obj)
                        case let .failure(error):
                            NCMBUser.logOutInBackground(callback: { result in
                                print("強制ログアウト")
                            })
                        }
                    })
                }
            case .inactive:
                print("scenePhase: inactive")
            case .background:
                print("scenePhase: background")
            @unknown default: break
            }
        }
    }
}
