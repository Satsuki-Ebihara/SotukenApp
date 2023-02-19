//
//  UserList.swift
//
//  Created by 海老原颯希 on 2023/02/12.
//

import UIKit
import Firebase
import Nuke
import NukeExtensions
import NukeUI
import Foundation


class UserListViewController: UIViewController  {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatUIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatUIButton.layer.cornerRadius = 10
        startChatUIButton.isEnabled = false
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 40, green: 50, blue: 70)
        fechUserInfoFirestore()
        
    }
    
    @IBAction func tappedChatStartUIButton(_ sender: Any) {
        print("tappedStartChatUIButton")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String: Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ルーム情報の保存に失敗しました\(err)")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            print("ルーム情報の保存に成功しました")
            
        }
    }
    
    
    
    private func fechUserInfoFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documents.forEach( {(snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
                
                
            })
        }
    }
    
    
}

    

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! userListTableViewCell
        cell.user = users[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatUIButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
    }
    
    
}



class userListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            if let url = URL(string: user?.profileImageUrl ?? "") {
                
                NukeExtensions.loadImage(with: url, into: userImageView)
                
            }
            
        }
    }
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super .awakeFromNib()
        userImageView.layer.cornerRadius = 25
    
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
