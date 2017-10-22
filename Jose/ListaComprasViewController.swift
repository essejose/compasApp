//
//  ListaComprasViewController.swift
//  jose
//
//  Created by jose on 15/10/17.
//  Copyright © 2017 jose. All rights reserved.
//

import UIKit
import CoreData

class ListaComprasViewController: UITableViewController {

    var dataSource = [Produto]()
    
    let sgEdit = "sgEdit"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        loadProdutos()
    }
    
    
    func validateList(_ empty: Bool) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.tintColor = .black
        label.alpha = 0.3
        tableView.backgroundView = !empty ? nil : label
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let listCount = dataSource.count
        if listCount == 0 {
            
            validateList(true)
            
            return 0
        } else {
            validateList(false)
            return listCount
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProduct", for: indexPath)
        let item = dataSource[indexPath.row]
        
        
        cell.textLabel?.text = item.nome
        
        if item.iof {
            let preco = item.preco.addIof
            
            
            if let estado = item.estado {
                cell.detailTextLabel?.text = preco.addImposto(imposto: (estado.imposto)).formatDolar
            }
        }else{
            
            
            if let estado = item.estado {
                cell.detailTextLabel?.text = item.preco.addImposto(imposto: (estado.imposto)).formatDolar
            
            }
        }
        
        if let image = item.image {
            
            cell.imageView?.image = image as? UIImage
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Deletar") { (action, indexPath) in
            self.delProduct(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = dataSource[indexPath.row]
        
        performSegue(withIdentifier: sgEdit, sender: item)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListaComprasViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == sgEdit {
        
            let produto = sender as! Produto
            
            let vcDestination = segue.destination as! ProdutoRegisterViewController
            vcDestination.produto = produto
        }
    }
    
    func delProduct(indexPath: IndexPath) {
        
        let produto = dataSource[indexPath.row] as Produto
        self.context.delete(produto)
        try! self.context.save()
        
        dataSource.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        loadProdutos()
    }
    
    func loadProdutos() {
        
        let fetchRequest: NSFetchRequest<Produto> = Produto.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try dataSource = context.fetch(fetchRequest)
            tableView.reloadData()
            if dataSource.count > 0 {
                validateList(false)
            } else {
                validateList(true)
            }
        } catch {
            print("Deu ruim")
        }
    }
}

