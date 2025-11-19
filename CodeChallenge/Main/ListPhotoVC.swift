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
        setupViewModel()
        viewModel.fetchPhotos()
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.register(UINib(nibName: "ListPhotoCells", bundle: nil),
                           forCellReuseIdentifier: "ListPhotoCells")
    }
    
    private func setupViewModel() {
        viewModel.onPhotosUpdated = { [weak self] in
            self?.tableview.reloadData()
        }
        viewModel.onError = { [weak self] message in
            print("Error: \(message)")
        }
    }
}

extension ListPhotoVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListPhotoCells", for: indexPath) as! ListPhotoCells
        let photo = viewModel.photo(at: indexPath)
        let screenWidth = UIScreen.main.bounds.width - 32
        let imageHeight = photo.calculatedHeight(for: screenWidth)
        cell.configure(with: photo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.estimatedHeight(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
