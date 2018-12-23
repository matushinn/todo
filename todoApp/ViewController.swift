//
//  ViewController.swift
//  todoApp
//
//  Created by 大江祥太郎 on 2018/12/17.
//  Copyright © 2018年 shotaro. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //テーブルの行数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
        
    }
    
    //テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //StoryBoardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell",for:indexPath)
        
        //行番号にあったToDoのタイトルを取得
        //let todoTitile = todoList[indexPath.row]
        let myTodo = todoList[indexPath.row]
        
        //セルのラベルにToDoのタイトルをセット
        //cell.textLabel?.text = todoTitile
        cell.textLabel?.text = myTodo.todoTitle
        //セルのチェックマーク状態をセット
        if myTodo.todoDone{
            //チェックあり
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            //チェックなし
            cell.accessoryType = UITableViewCell.AccessoryType.none
            
        }
        
        return cell
        
    }
    //セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone{
            //完了済みの場合は未完了に変更
            myTodo.todoDone = false
        }else{
            //未完の場合は完了済みに変更
            myTodo.todoDone = true
        }
        //セルの状態を変更
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        //データ保存。Data型にシリアライズする
        let data:Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
        //userDefaultsに保存
        let ud = UserDefaults.standard
        ud.set(data, forKey: "todoList")
        ud.synchronize()
    }
    
    //セルを消去した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //消去処理かどうか
        if editingStyle == UITableViewCell.EditingStyle.delete{
            //todoListから消去
            todoList.remove(at: indexPath.row)
            //セルを消去
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            //データ保存。Data型にシリアライズする
            let data:Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
            //ud保存
            let ud = UserDefaults.standard
            ud.set(data, forKey: "todoList")
            ud.synchronize()
        }
    }
    
    
    //todoリストを格納した配列
    var todoList = [MyTodo]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //保存しているToDoの読み込み処理
        let ud = UserDefaults.standard
        /*
        if let storedtodoList = ud.array(forKey: "todoList") as?[String] {
            todoList.append(contents0f:storedtodoList)
            
        }
 */
        if let storedTodoList = ud.object(forKey: "todoList") as? Data{
            if let unarchiveTodoList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyTodo]{
                todoList.append(contents0f:unarchiveTodoList)
            }
            
        }
    }

    @IBAction func tapAddButton(_ sender: Any) {
        //アラートダイアログを生成
        let alertController = UIAlertController(title: "todoList追加", message: "todoListを追加してください", preferredStyle: .alert)
        
        //テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        //OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            //OKボタンがタップされた時の処理
            if let textField = alertController.textFields?.first{
                /*
                //todoListの配列に入力ちを挿入。先頭に挿入する
                self.todoList.insert(textField.text!, at: 0)
 */
                //Todoの配列に入力値を挿入。先頭に挿入する。
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with:UITableView.RowAnimation.right)
                
                //ToDoの保存処理
                
                let ud = UserDefaults.standard
                //data型をシリアライズする
                let data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
                ud.set(data, forKey: "todoList")
                ud.synchronize()
            }
            
        }
        //okボタンがタップされた時の処理
        alertController.addAction(okAction)
        
        //cancelボタンがタップされた時の処理
        let cancelButton = UIAlertAction(title: "かキャンセル", style: .cancel, handler: nil)
        //cancelボタンを追加
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController,animated: true,completion: nil)
    }
    
}

//独自クラスを知りあらずする際には、NSObjectを継承し
//NSCodingプロトコルに準拠する必要がある
class MyTodo: NSObject,NSCoding {
    //Todoのタイトル
    var todoTitle:String?
    //Todoを完了したかどうかを表すフラグ
    var todoDone:Bool = false
    //コンストラクタ
    override init() {
        
    }
    
    //NSCodingプロトコルに宣言されているデシリアライズ処理。デコード処理とも呼ばれる。
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey:"todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
    
    //NSCordingプロトコルに宣言されているしリアライズ処理。エンコード処理とも言われる
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle,forKey:"todoTitle")
        aCoder.encode(todoDone,forKey:"todoDone")
    }
    
}

