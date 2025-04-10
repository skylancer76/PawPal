//
//  User Login.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class User_Login: UIViewController {
//    @IBOutlet weak var appLogo: UIImageView!
//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var loginButton: UIButton!
//    @IBOutlet weak var emailErrorLabel: UILabel!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Gradient Background Setup
//        let gradientView = UIView(frame: view.bounds)
//        gradientView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(gradientView)
//        view.sendSubviewToBack(gradientView)
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
//        gradientLayer.colors = [
//            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
//            UIColor.clear.cgColor
//        ]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientView.layer.insertSublayer(gradientLayer, at: 0)
//        
//        appLogo.layer.cornerRadius = appLogo.frame.height / 2
//        appLogo.layer.masksToBounds = true
//        loginButton.layer.cornerRadius = 10
//        loginButton.layer.masksToBounds = true
//        passwordTextField.isSecureTextEntry = true
//        
//        setupActivityIndicator()
//        emailErrorLabel.isHidden = true
//        
//        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)
//        
//        // Set self as delegate for text fields for border highlighting
//        emailTextField.delegate = self
//        passwordTextField.delegate = self
//    }
//    
//    @objc private func didTapView() {
//        view.endEditing(true)
//        // Hide error label and reset email field border
//        emailErrorLabel.isHidden = true
//        emailTextField.layer.borderWidth = 0
//        emailTextField.layer.borderColor = UIColor.clear.cgColor
//    }
//    
//    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
//        guard let email = textField.text else { return }
//        
//        // Always use systemPink for the border regardless of validity
//        textField.layer.borderWidth = 1
//        textField.layer.borderColor = UIColor.systemPink.cgColor
//        textField.layer.cornerRadius = 8
//        
//        if isValidEmail(email) {
//            emailErrorLabel.isHidden = true
//        } else {
//            emailErrorLabel.isHidden = false
//        }
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//        return predicate.evaluate(with: email)
//    }
//    
//    @IBAction func passwordViewTapped(_ sender: UIButton) {
//        passwordTextField.isSecureTextEntry.toggle()
//        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
//        sender.setImage(UIImage(systemName: imageName), for: .normal)
//    }
//    
//    @IBAction func loginClicked(_ sender: Any) {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            showAlert("Error", "Please fill in all fields")
//            return
//        }
//        
//        showLoadingIndicator() // shows the spinner
//        
//        // Firebase Login
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                self.hideLoadingIndicator()
//                self.showAlert("Login Failed", error.localizedDescription)
//                return
//            }
//            
//            guard let user = authResult?.user else {
//                self.hideLoadingIndicator()
//                self.showAlert("Error", "User not found")
//                return
//            }
//            
//            // Use DispatchGroup to combine caretaker and dog walker checks
//            let group = DispatchGroup()
//            var isCaretaker = false
//            var isDogwalker = false
//            
//            group.enter()
//            self.checkIfUserIsCaretaker(userID: user.uid) { result in
//                isCaretaker = result
//                group.leave()
//            }
//            
//            group.enter()
//            self.checkIfUserIsDogWalker(userID: user.uid) { result in
//                isDogwalker = result
//                group.leave()
//            }
//            
//            group.notify(queue: .main) {
//                self.hideLoadingIndicator()
//                if isCaretaker || isDogwalker {
//                    self.navigateToCaretakerHome()
//                } else {
//                    self.navigateToRegularHome()
//                }
//            }
//        }
//    }
//    
//    // MARK: - Activity Indicator
//    
//    private lazy var activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .large)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.hidesWhenStopped = true
//        return indicator
//    }()
//    
//    private func setupActivityIndicator() {
//        view.addSubview(activityIndicator)
//        NSLayoutConstraint.activate([
//            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    private func showLoadingIndicator() {
//        activityIndicator.startAnimating()
//        view.isUserInteractionEnabled = false
//    }
//    
//    private func hideLoadingIndicator() {
//        activityIndicator.stopAnimating()
//        view.isUserInteractionEnabled = true
//    }
//    
//    // MARK: - Role Checking Methods
//    
//    func checkIfUserIsCaretaker(userID: String, completion: @escaping (Bool) -> Void) {
//        let db = Firestore.firestore()
//        let caretakersRef = db.collection("caretakers")
//        
//        caretakersRef.whereField("caretakerId", isEqualTo: userID).getDocuments { snapshot, error in
//            if let error = error {
//                print("Error verifying caretaker role: \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//            if let snapshot = snapshot, !snapshot.documents.isEmpty {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
//    
//    func checkIfUserIsDogWalker(userID: String, completion: @escaping (Bool) -> Void) {
//        let db = Firestore.firestore()
//        let dogWalkersRef = db.collection("dogwalkers")
//        
//        dogWalkersRef.whereField("dogWalkerId", isEqualTo: userID).getDocuments { snapshot, error in
//            if let error = error {
//                print("Error verifying dog walker role: \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//            if let snapshot = snapshot, !snapshot.documents.isEmpty {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
//    
//    // MARK: - Navigation Methods
//    
//    func navigateToCaretakerHome() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let caretakerTabBarVC = storyboard.instantiateViewController(withIdentifier: "CaretakerTabBarController") as? UITabBarController {
//            caretakerTabBarVC.modalPresentationStyle = .fullScreen
//            self.present(caretakerTabBarVC, animated: true, completion: nil)
//        } else {
//            self.showAlert("Error", "Caretaker home could not be loaded.")
//        }
//    }
//    
//    func navigateToRegularHome() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let userTabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
//            userTabBarVC.modalPresentationStyle = .fullScreen
//            self.present(userTabBarVC, animated: true, completion: nil)
//        } else {
//            self.showAlert("Error", "User home could not be loaded.")
//        }
//    }
//    
//    // MARK: - Helper
//    
//    func showAlert(_ title: String, _ message: String) {
//        let alert = UIAlertController(title: title,
//                                      message: message,
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//// MARK: - UITextFieldDelegate for Border Highlighting
//
//extension User_Login: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        // When editing begins, show a systemPink border
//        textField.layer.borderWidth = 1
//        textField.layer.borderColor = UIColor.systemPink.cgColor
//        textField.layer.cornerRadius = 8
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        // For emailTextField, if not empty and valid, remove the border; otherwise, keep it.
//        if textField == emailTextField {
//            if let email = textField.text, !email.isEmpty, isValidEmail(email) {
//                textField.layer.borderWidth = 0
//                textField.layer.borderColor = UIColor.clear.cgColor
//            } else {
//                // Keep the systemPink border if invalid
//                textField.layer.borderWidth = 1
//                textField.layer.borderColor = UIColor.systemPink.cgColor
//            }
//        } else {
//            // For passwordTextField, remove the border when editing ends.
//            textField.layer.borderWidth = 0
//            textField.layer.borderColor = UIColor.clear.cgColor
//        }
//    }
//}


import UIKit
import FirebaseAuth
import FirebaseFirestore

class User_Login: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! // Connect this in storyboard
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gradient Background Setup
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        appLogo.layer.cornerRadius = appLogo.frame.height / 2
        appLogo.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
        
        setupActivityIndicator()
        emailErrorLabel.isHidden = true
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Set self as delegate for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.clear.cgColor
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
        
        emailErrorLabel.isHidden = isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    @IBAction func passwordViewTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Error", "Please fill in all fields")
            return
        }
        
        showLoadingIndicator()
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert("Login Failed", error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.hideLoadingIndicator()
                self.showAlert("Error", "User not found")
                return
            }
            
            let group = DispatchGroup()
            var isCaretaker = false
            var isDogwalker = false
            
            group.enter()
            self.checkIfUserIsCaretaker(userID: user.uid) { result in
                isCaretaker = result
                group.leave()
            }
            
            group.enter()
            self.checkIfUserIsDogWalker(userID: user.uid) { result in
                isDogwalker = result
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.hideLoadingIndicator()
                if isCaretaker || isDogwalker {
                    self.navigateToCaretakerHome()
                } else {
                    self.navigateToRegularHome()
                }
            }
        }
    }
    
    // MARK: - Keyboard Handling
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Activity Indicator
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Role Checking Methods
    
    func checkIfUserIsCaretaker(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let caretakersRef = db.collection("caretakers")
        
        caretakersRef.whereField("caretakerId", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error verifying caretaker role: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(snapshot?.documents.isEmpty == false)
        }
    }
    
    func checkIfUserIsDogWalker(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let dogWalkersRef = db.collection("dogwalkers")
        
        dogWalkersRef.whereField("dogWalkerId", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error verifying dog walker role: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(snapshot?.documents.isEmpty == false)
        }
    }
    
    // MARK: - Navigation Methods
    
    func navigateToCaretakerHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let caretakerTabBarVC = storyboard.instantiateViewController(withIdentifier: "CaretakerTabBarController") as? UITabBarController {
            caretakerTabBarVC.modalPresentationStyle = .fullScreen
            self.present(caretakerTabBarVC, animated: true, completion: nil)
        } else {
            self.showAlert("Error", "Caretaker home could not be loaded.")
        }
    }
    
    func navigateToRegularHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userTabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
            userTabBarVC.modalPresentationStyle = .fullScreen
            self.present(userTabBarVC, animated: true, completion: nil)
        } else {
            self.showAlert("Error", "User home could not be loaded.")
        }
    }
    
    // MARK: - Helper
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension User_Login: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if let email = textField.text, !email.isEmpty, isValidEmail(email) {
                textField.layer.borderWidth = 0
                textField.layer.borderColor = UIColor.clear.cgColor
            } else {
                textField.layer.borderWidth = 1
                textField.layer.borderColor = UIColor.systemPink.cgColor
            }
        } else {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
