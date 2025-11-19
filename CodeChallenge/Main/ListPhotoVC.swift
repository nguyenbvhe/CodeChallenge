//
//  ListPhotoVC.swift
//  CodeChallenge
//
//  Created by minhnguyen on 19/11/25.
//
import UIKit

class ListPhotoVC: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    private let viewModel = PhotoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchField()
        setupViewModel()
        viewModel.fetchPhotos()
    }
    private func setupTableView() {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
            tableview.keyboardDismissMode = .onDrag
            tableview.register(UINib(nibName: "ListPhotoCells", bundle: nil),
                               forCellReuseIdentifier: "ListPhotoCells")
        }
        
        private func setupSearchField() {
            searchTextField.delegate = self
            searchTextField.placeholder = "Tìm author hoặc id (tối đa 15 ký tự)"
            searchTextField.returnKeyType = .search
            searchTextField.enablesReturnKeyAutomatically = true
            
            // Icon search
            let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            icon.tintColor = .systemGray
            icon.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            icon.contentMode = .center
            searchTextField.leftView = icon
            searchTextField.leftViewMode = .always
            
            searchTextField.clearButtonMode = .whileEditing
            
            // Style 
            searchTextField.layer.cornerRadius = 14
            searchTextField.layer.borderWidth = 1.5
            searchTextField.layer.borderColor = UIColor.systemGray4.cgColor
            searchTextField.backgroundColor = .systemGray6
            
            // Shadow khi focus
            searchTextField.layer.shadowColor = UIColor.systemBlue.cgColor
            searchTextField.layer.shadowOpacity = 0
            searchTextField.layer.shadowRadius = 8
            searchTextField.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        private func setupViewModel() {
            viewModel.onPhotosUpdated = { [weak self] in
                self?.tableview.reloadData()
            }
            viewModel.onError = { message in
                print("Error: \(message)")
            }
        }
    }

    // MARK: - TableView
    extension ListPhotoVC: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            viewModel.numberOfRows()
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListPhotoCells", for: indexPath) as! ListPhotoCells
            let photo = viewModel.photo(at: indexPath)
            let width = UIScreen.main.bounds.width - 32
            let height = photo.calculatedHeight(for: width)
            cell.configure(with: photo)
            return cell
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            viewModel.estimatedHeight(at: indexPath)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            UITableView.automaticDimension
        }
    }

    // MARK: - UITextFieldDelegate + Validate
    extension ListPhotoVC: UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let current = textField.text ?? ""
            var newText = (current as NSString).replacingCharacters(in: range, with: string)
            
            if newText.count > 15 {
                newText = String(newText.prefix(15))
            }
            
         
            newText = newText.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            
            let allowed = CharacterSet.alphanumerics
                .union(CharacterSet(charactersIn: "!@#$%^&*():.,<>/\\[]?"))
            
            newText = newText.unicodeScalars
                .filter { allowed.contains($0) }
                .map { String($0) }
                .joined()
                .lowercased()
            
            textField.text = newText
            viewModel.filterPhotos(with: newText)
            return false
        }
        
        // Bấm nút Search trên bàn phím => ẩn
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Hiệu ứng focus
        func textFieldDidBeginEditing(_ textField: UITextField) {
            UIView.animate(withDuration: 0.25) {
                textField.layer.borderColor = UIColor.systemBlue.cgColor
                textField.layer.shadowOpacity = 0.4
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            UIView.animate(withDuration: 0.25) {
                textField.layer.borderColor = UIColor.systemGray4.cgColor
                textField.layer.shadowOpacity = 0
            }
        }
    }

