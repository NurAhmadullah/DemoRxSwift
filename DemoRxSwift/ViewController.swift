//
//  ViewController.swift
//  DemoRxSwift
//
//  Created by BJIT on 11/1/24.
//

import UIKit
import RxSwift
import RxCocoa

struct Product{
    let imageName:String
    let title:String
}

struct ProductViewModel{
    var items = PublishSubject<[Product]> ()
    
    func fetchItems(){
        let products = [
            Product(imageName: "house", title: "Home"),
            Product(imageName: "gear", title: "Settings"),
            Product(imageName: "person.circle", title: "Profile"),
            Product(imageName: "airplane", title: "Flights"),
            Product(imageName: "bell", title: "Activity")
        ]
        items.onNext(products)
        items.onCompleted()
    }
}

class ViewController: UIViewController {
    
    private var tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var viewModel = ProductViewModel()
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        self.tableView.frame = self.view.bounds
        
        
        self.bindTableData()
    }

    private func bindTableData(){
        // bind items to table-view
        viewModel.items.bind(
            // below line return similar to deque-reusable-tv-cell
            to: tableView.rx.items(
                cellIdentifier: "cell",
                cellType: UITableViewCell.self)
        ){row,model,cell in
            //--- this is the place, where we do in cell-for-row-at
            cell.textLabel?.text = model.title
            cell.imageView?.image = UIImage(systemName: model.imageName)
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(Product.self).bind{ model in
            //--- this place is where did-select-tableview
            print("title: \(model.title)")
        }.disposed(by: bag)
        
        
        //--- below to set delegate, to use delegate methods
        tableView.rx.setDelegate(self).disposed(by: bag)
                
        // fetch items
        viewModel.fetchItems()
    }

}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
