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
                NCMB.initialize(applicationKey: "YOUR_APPLICATION_KEY", clientKey: "YOUR_CLIENT_KEY")
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
