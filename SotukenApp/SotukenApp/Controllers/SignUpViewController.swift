//
//  SignUpViewController.swift
//
//  Created by 海老原颯希 on 2023/02/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD
import Foundation
import FirebaseAuthInterop
import FirebaseAuthCombineSwift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func createUserToFireStore(profileImageUrl: String) {
        print("tappedRegister")
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}


        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                return
            }
            print("認証情報の保存に成功しました。")

            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            let dogData = [

                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl

            ]

            Firestore.firestore().collection("users").document(uid).setData(dogData) {
                (err) in
                if let err = err {
                    print("データベースへの保存に失敗しました\(err)")
                    return
                }
                
                print("Firestoreへの情報の保存が成功しました")
                Auth.auth().currentUser?.sendEmailVerification { (err) in
                    if err != nil {
                        print("認証メールの送信に失敗しました")
                    }
                    print("認証メールを送信しました")
                    
                }
                    //self.dismiss(animated: true, completion: nil)
            
//                let storyboard: UIStoryboard = self.storyboard!
//                let nextView = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                self.present(nextView, animated: true, completion: nil)
                
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    let nav = UINavigationController.init(rootViewController: LoginViewController)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                
                
            }
        }
        
    }
    
    private func setUpViews() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        registerButton.layer.cornerRadius = 15
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        registerButton.isEnabled = false
    }
    
    
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        func createUserToFireStore(profileImageUrl: String) {
            print("tappedRegister")
            guard let email = emailTextField.text else {return}
            guard let password = passwordTextField.text else {return}
            HUD.show(.progress)
            
            Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
                if let err = err {
                    print("認証情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                print("認証情報の保存に成功しました。")
                
                guard let uid = res?.user.uid else { return }
                guard let username = self.usernameTextField.text else { return }
                let dogData = [
                    
                    "email": email,
                    "username": username,
                    "createdAt": Timestamp(),
                    "profileImageUrl": profileImageUrl
                    
                ]
                //ebienv0426@gmail.com
                Firestore.firestore().collection("users").document(uid).setData(dogData) {
                    (err) in
                    if let err = err {
                        print("データベースへの保存に失敗しました\(err)")
                        HUD.hide()
                        return
                    }
                    
                    print("Firestoreへの情報の保存が成功しました")
                    HUD.hide()
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        
                
}
        
        
        
        let image = profileImageButton.imageView?.image ?? UIImage(named: "modric")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestoreへの画像の保存に失敗しました\(err)")
                return
            }
            print("Firestoreへの画像の保存に成功しました")
            storageRef.downloadURL { (url, err) in
                
                if let err = err {
                    print("FireStoreからのダウンロードに失敗しました\(err)")
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                print("urlString :", urlString)
                self.createUserToFireStore(profileImageUrl: urlString)
            }
        }
        
    }
    
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        //print("tappedImage")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
            //print(" textField.text: ",textField.text)
            let emailIsEmpty = emailTextField.text?.isEmpty ?? false
            let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
            let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
    //        guard let email = emailTextField.text else {return}
            //guard let emailIsEnable = emailTextField.text?.contains("g.metro-cit.ac.jp") else {return}
            
            
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty /*||(emailIsEnable == false)*/{
                registerButton.isEnabled = false
                registerButton.backgroundColor = .gray
            } else {
                registerButton.isEnabled = true
                registerButton.backgroundColor = .systemMint
            }
        }
        }

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage{
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage
        {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
}
