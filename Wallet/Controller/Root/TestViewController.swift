import UIKit
import CoreKit
import CryptoKit

class TestViewController: UIViewController {
    let decrypted = UILabel()
    let input = UITextField()
    let password = UITextField()
    let encrypted = UILabel()
    
    let encrypt = UILabel()
    let decrypt = UILabel()
    let reset = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        encrypt.backgroundColor = .red
        decrypt.backgroundColor = .blue
        reset.backgroundColor = .darkGray
        
        input.clipsToBounds = true
        password.clipsToBounds = true
        encrypt.clipsToBounds = true
        decrypt.clipsToBounds = true
        reset.clipsToBounds = true
        
        input.layer.borderWidth = 0.33
        input.layer.borderColor = UIColor.systemGray.cgColor
        password.layer.borderWidth = 0.33
        password.layer.borderColor = UIColor.systemGray.cgColor
        
        input.layer.cornerRadius = 8
        password.layer.cornerRadius = 8
        encrypt.layer.cornerRadius = 8
        decrypt.layer.cornerRadius = 8
        reset.layer.cornerRadius = 8
        
        encrypt.text = "Encrypt"
        encrypt.textAlignment = .center
        encrypt.textColor = .white
        
        decrypt.text = "Decrypt"
        decrypt.textAlignment = .center
        decrypt.textColor = .white
        
        reset.text = "Reset"
        reset.textAlignment = .center
        reset.textColor = .white
        
        decrypted.interactive = true
        encrypted.interactive = true
        encrypt.interactive = true
        decrypt.interactive = true
        reset.interactive = true
        
        decrypted.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_copyDecrypted)))
        encrypted.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_copyEncrypted)))
        encrypt.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_encrypt)))
        decrypt.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_decrypt)))
        reset.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_reset)))
        view.add(gesture: UITapGestureRecognizer(target: self, action: #selector(_hideKeyboard)))
        
        decrypted.auto = false
        input.auto = false
        password.auto = false
        encrypted.auto = false
        encrypt.auto = false
        decrypt.auto = false
        reset.auto = false
        
        view.add(decrypted)
        view.add(input)
        view.add(password)
        view.add(encrypted)
        view.add(encrypt)
        view.add(decrypt)
        view.add(reset)
        
        decrypted.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64).isActive = true
        decrypted.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        decrypted.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        decrypted.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        input.topAnchor.constraint(equalTo: decrypted.bottomAnchor, constant: 32).isActive = true
        input.centerXAnchor.constraint(equalTo: decrypted.centerXAnchor).isActive = true
        input.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        input.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        password.topAnchor.constraint(equalTo: input.bottomAnchor, constant: 32).isActive = true
        password.centerXAnchor.constraint(equalTo: input.centerXAnchor).isActive = true
        password.widthAnchor.constraint(equalTo: input.widthAnchor).isActive = true
        password.heightAnchor.constraint(equalTo: input.heightAnchor).isActive = true
        
        encrypted.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 32).isActive = true
        encrypted.leftAnchor.constraint(equalTo: decrypted.leftAnchor).isActive = true
        encrypted.rightAnchor.constraint(equalTo: decrypted.rightAnchor).isActive = true
        encrypted.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        encrypt.topAnchor.constraint(equalTo: encrypted.bottomAnchor, constant: 32).isActive = true
        encrypt.leftAnchor.constraint(equalTo: encrypted.leftAnchor).isActive = true
        encrypt.rightAnchor.constraint(equalTo: encrypted.centerXAnchor, constant: -16).isActive = true
        encrypt.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        decrypt.topAnchor.constraint(equalTo: encrypted.bottomAnchor, constant: 32).isActive = true
        decrypt.leftAnchor.constraint(equalTo: encrypted.centerXAnchor, constant: 16).isActive = true
        decrypt.rightAnchor.constraint(equalTo: encrypted.rightAnchor).isActive = true
        decrypt.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        reset.topAnchor.constraint(equalTo: encrypt.bottomAnchor, constant: 32).isActive = true
        reset.leftAnchor.constraint(equalTo: encrypt.leftAnchor).isActive = true
        reset.rightAnchor.constraint(equalTo: decrypt.rightAnchor).isActive = true
        reset.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    @objc
    private func _encrypt() {
        _hideKeyboard()
        guard let secret = input.text,
              let password = password.text,
              let encrypted = encrypt(secret: secret, with: password)
        else { return }
        self.decrypted.text = secret
        self.encrypted.text = encrypted.base64EncodedString()
        self.input.text = nil
        self.password.text = nil
    }
    @objc
    private func _decrypt() {
        _hideKeyboard()
        guard let secret = input.text,
              let password = password.text,
              let decrypted = decrypt(secret: secret, with: password)
        else { return }
        self.decrypted.text = String(data: decrypted, encoding: .utf8)
        self.encrypted.text = secret
        self.input.text = nil
        self.password.text = nil
    }
    @objc
    private func _reset() {
        _hideKeyboard()
        decrypted.text = nil
        input.text = nil
        password.text = nil
        encrypted.text = nil
    }
    @objc
    private func _hideKeyboard() {
        input.resignFirstResponder()
        password.resignFirstResponder()
    }
    @objc
    private func _copyDecrypted() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        UIPasteboard.general.string = decrypted.text
        generator.notificationOccurred(.success)
    }
    @objc
    private func _copyEncrypted() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        UIPasteboard.general.string = encrypted.text
        generator.notificationOccurred(.success)
    }
}

extension TestViewController {
    public func encrypt(secret: String, with password: String) -> Data? {
        guard let data = secret.data,
              let key = password.key,
              let encrypted = try? ChaChaPoly.seal(data, using: key).combined
        else { print("failed to encrypt"); return nil }
        return encrypted
    }
    public func decrypt(secret: String, with password: String) -> Data? {
        guard let data = Data(base64Encoded: secret),
              let key = password.key,
              let box = try? ChaChaPoly.SealedBox(combined: data),
              let decrypted = try? ChaChaPoly.open(box, using: key)
        else { print("failed to decrypt"); return nil }
        return decrypted
    }
}
extension String {
    public var data: Data? {
        guard let data = data(using: .utf8) else {
            print("failed to create data from text: \(self)")
            return nil
        }
        return data
    }
    public var key: SymmetricKey? {
        guard let data else { print("failed to create key from text: \(self)"); return nil }
        return SymmetricKey(data: SHA256.hash(data: data))
    }
}
