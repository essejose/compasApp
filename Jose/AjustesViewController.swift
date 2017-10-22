//
//  AjustesViewController.swift
//  jose
//
//  Created by jose on 15/10/17.
//  Copyright © 2017 jose. All rights reserved.
//

import UIKit
import CoreData

class AjustesViewController: UIViewController {

  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    
    var dataSource = [Estado]()
    var helpToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        helpToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadImposto()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadEstados()
    }
    
    @IBAction func addNewState(_ sender: UIButton) {
        
        registerEstado()
    }
}

//MARK: - Methods
extension AjustesViewController {
    func loadImposto() {
        
        if let dolar = UserDefaults.standard.string(
            forKey: "dolar"){
            tfDolar.text = dolar
        
        }
        if let iof = UserDefaults.standard.string(forKey: "iof"){
            tfIOF.text = iof
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func hasDefaultEstados(){
       
        if let loadEstadosFirst = UserDefaults.standard.string(
            forKey: "EstadosPadroes"){
            
            if loadEstadosFirst.toBool()!{
                
                let defaultEstados :[String:Double] = [
                    
                    "California" : UserDefaults.standard.double(forKey: "California"),
                    "New York"   : UserDefaults.standard.double(forKey: "New York"),
                    "Texas"      : UserDefaults.standard.double(forKey: "Texas")
                ]
                
                    for defaultEstado  in defaultEstados{
                        
                        let estado = Estado(context: self.context)
                        estado.nome = defaultEstado.0
                        estado.imposto = defaultEstado.1
                        
                        do {
                            try self.context.save()
                        } catch {
                        
                    }
                
                }
                
                UserDefaults.standard.set(String(false), forKey: "EstadosPadroes")
                
            }
        }
        
    }
    
    func loadEstados() {
        
        
        validateListProdutos(true)
        dataSource.removeAll()
        hasDefaultEstados()
        
        
        
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try dataSource = context.fetch(fetchRequest)
        
            tableView.reloadData()
            
            if dataSource.count > 0 {
                validateListProdutos(false)
            } else {
                validateListProdutos(true)
            }
            
        } catch {
            print("deu ruim ")
        }
    }
    
    func helpToolBar() {
        helpToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let btEdit = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editTaxTotal))
        
        helpToolbar.items = [btCancel,space,btEdit]
        tfDolar.inputAccessoryView = helpToolbar
        tfIOF.inputAccessoryView = helpToolbar
    }
    
    func alertValidate(_ name:String, _ tax:String) -> Bool {
        var valid : Bool {
            if (!name.isEmpty && !tax.isEmpty) {
                if let _ = Double(tax) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        return valid
    }
    
    func editEstado(item: Estado) {
        let alert = UIAlertController(title: "Editar", message: "Editar Estado", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.text = item.nome
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Taxa de Imposto"
            textField.keyboardType = .numberPad
            textField.text = "\(item.imposto)"
        }
        
        let okAction = UIAlertAction(title: "Salvar", style: .default) { (action) in
            if self.alertValidate(alert.textFields![0].text!,
                                  alert.textFields![1].text!) {
                
                item.nome = alert.textFields![0].text
                if let impostoEstado = Double(alert.textFields![1].text!.replacingOccurrences(of: ",", with: ".")) {
                    item.imposto = impostoEstado
                    do {
                        try self.context.save()
                        self.loadEstados()
                    } catch { }
                }
            } else {
                self.loadEstados()
                self.alertRequired()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func registerEstado() {
        let alert = UIAlertController(title: "Novo", message: "Novo Estado", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Taxa de Imposto"
            textField.keyboardType = .decimalPad
        }
        
        let okAction = UIAlertAction(title: "Salvar", style: .default) { (action) in
            if self.alertValidate(alert.textFields![0].text!,alert.textFields![1].text!.replacingOccurrences(of: ",", with: ".")) {
                let estado = Estado(context: self.context)
                estado.nome = alert.textFields![0].text
                if let impostoEstado = Double(alert.textFields![1].text!.replacingOccurrences(of: ",", with: ".")) {
                    estado.imposto = impostoEstado
                    do {
                        try self.context.save()
                        self.loadEstados()
                    } catch {
                        
                    }
                }
                
            } else {
                self.loadEstados()
                self.alertRequired()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func alertInvalid() {
        let alert = UIAlertController(title: "Atenção",
                                      message: "Taxa de Imposto está incorreta.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: false, completion: nil)
    }
    
    func alertRequired() {
        let alert = UIAlertController(title: "Atenção",
                                      message: "Todos os campos são obrigatórios.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: false, completion: nil)
    }
    
    func cancel() {
        self.becomeFirstResponder()
    }
    
    func editTaxTotal() {
        
        if tfDolar.isFirstResponder {
            if let dolar = Double((tfDolar.text?.replacingOccurrences(of: ",", with: "."))!) {
                UserDefaults.standard.set(String(dolar), forKey:"dolar")
            } else {
                let alert = UIAlertController(title: "Atenção",
                                              message: "Cotação do dolar está incorreto!",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
            self.becomeFirstResponder()
        }
        if tfIOF.isFirstResponder {
            if let iof = Double((tfIOF.text?.replacingOccurrences(of: ",", with: "."))!) {
                UserDefaults.standard.set(String(iof), forKey: "iof")
            } else {
                let alert = UIAlertController(title: "Atenção",
                                              message: "O campo iof está incorreto!",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
            self.becomeFirstResponder()
        }
    }
    
    func del(indexPath: IndexPath) {
        let state = dataSource[indexPath.row] as Estado
        self.context.delete(state)
        
        try! self.context.save()
        
        dataSource.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func validateListProdutos(_ empty: Bool) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        
        label.text = "Sem Estados"
        label.textAlignment = .center
        label.tintColor = .black
        label.alpha = 0.3
        
        tableView.backgroundView = !empty ? nil : label
    
    }
}

extension AjustesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Deletar") { (action, indexPath) in
            self.del(indexPath: indexPath)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editEstado(item: dataSource[indexPath.row])
    }
}

extension AjustesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let listTotal = dataSource.count
        if listTotal == 0 {
            validateListProdutos(true)
            return 0
        } else {
            validateListProdutos(false)
            return listTotal
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellState", for: indexPath)
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.nome
        cell.detailTextLabel?.text = "\(String(state.imposto)) %"
        return cell
    }
}

