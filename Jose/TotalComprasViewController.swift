//
//  TotalComprasViewController.swift
//  jose
//
//  Created by jose on 15/10/17.
//  Copyright © 2017 jose. All rights reserved.
//

import UIKit
import CoreData


class TotalComprasViewController: UIViewController {

    @IBOutlet weak var tfDolarTotal: UILabel!
    
    @IBOutlet weak var tfRealTotal: UILabel!
    
    var dataSource = [Produto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        loadProdutos()
    }
    
    func loadProdutos() {
        
        let fetchRequest: NSFetchRequest<Produto> = Produto.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try dataSource = context.fetch(fetchRequest)
            setLabels()
        } catch {
            print("deu ruim")
        }
    }
    
    func totalDolar() -> Double {
        var items = [Double]()
        for item in dataSource {
            var preco = item.preco
            
            if item.iof {
                
                preco = preco.addIof
            }
            items.append(preco.addImposto(imposto: (item.estado?.imposto)!))
        }
        let total = items.reduce(0,+)
        return total
    }
    
    
    
    func totalReal() -> Double {
        
        let dolar = UserDefaults.standard.double(forKey:"dolar")
        
        var items = [Double]()
        for item in dataSource {
            var preco = item.preco
            if item.iof {
                preco = preco.addIof
            }
            items.append(preco.addImposto(imposto: (item.estado?.imposto)!))
        }
        let total = items.reduce(0,+)*dolar
        return total
    }
    
    func setLabels() {
        tfDolarTotal.text = totalDolar().formatDolar
        tfRealTotal.text = totalReal().formatReal
}
}


