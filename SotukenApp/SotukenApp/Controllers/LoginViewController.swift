//
//  LoginViewController.swift
//
//  Created by 海老原颯希 on 2023/02/12.
//

import UIKit
import Firebase
import PKHUD


class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
    }
    
    
    
    @IBAction func tappedForgetPasswordButton(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                print("error")
                let alert = UIAlertController(title: "メールアドレスが入力されていません", message: "emailテキストボックスに登録したメールアドレスを入力し再度ボタンを押してください", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
            }else{
                print("success")
            }
        }
    }
    
    
    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err{
                print("ログインに失敗しました\(err)")
                HUD.hide()
                let alert = UIAlertController(title: "ログインに失敗しました", message: "入力したメールアドレスとパスワードを再度ご確認下さい", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                return
            }
            
                
                HUD.hide()
            
            Auth.auth().signIn(withEmail: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "") { authResult, error in
                if let user = authResult?.user {
                    if user.isEmailVerified {
                        print("メールアドレス確認済み")
                        
                        print("ログインに成功しました")
                        let nav = self.presentingViewController as! UINavigationController
                        let chatListViewController = nav.viewControllers[nav.viewControllers.count - 1] as? ChatListViewController
                        chatListViewController?.fetchChatRoomsInfoFromFirestore()
                        
                        let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
                        let ChatListViewController = storyboard.instantiateViewController(withIdentifier: "ChatListViewController")
                        let nv = UINavigationController.init(rootViewController: ChatListViewController)
                        nv.modalPresentationStyle = .fullScreen
                        self.present(nv, animated: true, completion: nil)
                        
                    } else {
                        HUD.hide()
                        print("メールアドレス未確認")
                        
                        print("メールの認証が終わっていません")
                        let alert = UIAlertController(title: "ログインに失敗しました", message: "メールアドレスの認証を行ってください", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                    }
                }
            }
                
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
