//
//  ContentView.swift
//  todoapp
//
//  Created by Atsushi on 2021/04/05.
//

import SwiftUI
import NCMB
import Combine

class Todos: ObservableObject {
    @Published var todos: [NCMBObject] = []
}

struct ContentView: View, InputViewDelegate, EditViewDelegate {
    @ObservedObject var Todo = Todos()
        
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(self.Todo.todos, id: \.objectId) { todo in
                        NavigationLink(destination: EditView(delegate: self, objectId: todo.objectId!, text: (todo["body"] ?? "") as String)) {
                            Text((todo["body"] ?? "") as String)
                        }
                    }
                    .onDelete(perform: delete)
                }
                
                NavigationLink(destination: InputView(delegate: self, text: "")) {
                    Text("Add")
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 20))
                }
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .cornerRadius(30)
                .padding()
                
            }
            .onAppear {
                let query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "Todo")
                query.findInBackground(callback: { result in
                    switch result {
                        case let .success(array):
                            DispatchQueue.main.async {
                                self.Todo.todos = array
                            }
                        case let .failure(error):
                            print("取得に失敗しました: \(error)")
                    }
                })
            }
            .navigationTitle("TODO")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func delete(at offsets: IndexSet) {
        let todo = self.Todo.todos[Array(offsets)[0]] as NCMBObject
        let result = todo.delete()
        switch result {
            case .success(_):
                self.Todo.todos.remove(atOffsets: offsets)
            case let .failure(error):
                print(error)
        }
    }
    
    func addTodo(text: String) {
        let obj = NCMBObject(className: "Todo")
        obj["body"] = text
        var acl = NCMBACL.empty
        let user = NCMBUser.currentUser!
        acl.put(key: user.objectId!, readable: true, writable: true)
        acl.put(key: "role:Admin", readable: true, writable: false)
        obj.acl = acl
        
        obj.saveInBackground(callback: { result in
            switch result {
                case .success(_):
                    self.Todo.todos.append(obj)
                case let .failure(error):
                    print("作成に失敗しました: \(error)")
            }
        })
    }
    
    func editTodo(text: String, objectId: String) {
        if let i = self.Todo.todos.firstIndex(where: { $0.objectId == objectId}) {
            let obj = self.Todo.todos[i]
            obj["body"] = text
            obj.saveInBackground(callback: { result in
                switch result {
                    case .success(_):
                        self.Todo.todos[i] = obj
                    case let .failure(error):
                        print("更新に失敗しました: \(error)")
                }
            })
        }
    }
}

protocol EditViewDelegate {
    func editTodo(text: String, objectId: String)
}

struct EditView: View {
    @Environment(\.presentationMode) var presentation
    let delegate: EditViewDelegate
    @State var objectId: String
    @State var text: String
    var body: some View {
        VStack(spacing: 16) {
            TextField("タスクを編集してください", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("編集") {
                delegate.editTodo(text: text, objectId: objectId)
                presentation.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

protocol InputViewDelegate {
    func addTodo(text: String)
}

struct InputView: View {
    @Environment(\.presentationMode) var presentation
    let delegate: InputViewDelegate
    @State var text: String
    var body: some View {
        VStack(spacing: 16) {
            TextField("タスクを追加してください", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("追加") {
                delegate.addTodo(text: text)
                presentation.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
