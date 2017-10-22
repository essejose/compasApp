//
//  ProdutoRegisterViewController.swift
//  jose
//
//  Created by jose on 13/10/17.
//  Copyright © 2017 jose. All rights reserved.
//

import UIKit
import CoreData

class ProdutoRegisterViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tfProdutoNome: UITextField!
    @IBOutlet weak var tfEstadoCompra: UITextField!
    @IBOutlet weak var tfPreco: UITextField!
    @IBOutlet weak var imgProduto: UIImageView!
    @IBOutlet weak var swIOF: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnSave: UIButton!
    
    var pickerView: UIPickerView!
    var estadoSelecionado: Estado?
    var imgSelecionada: UIImage?
    var dataSource: [Estado]!
    var hasCard = false
    var smallImage = UIImage()
    var produto: Produto?
    var toolbar = UIToolbar()
    
    var iof: Double!
    var tax: Double!
    var viewPosition: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        tfEstadoCompra.delegate = self
        tfEstadoCompra.inputView = pickerView
    
    
        addToolBar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        isEdit()
        loadEstados()
    }
    
    @IBAction func hasCardAction(_ sender: UISwitch) {
        hasCard = sender.isOn
    }
    
    @IBAction func saveProduct(_ sender: UIButton) {
        saveProduct()
    }
    
    @IBAction func getImg(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar imagem",
                                      message: "Como você deseja escolher a imagem?",
                                      preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) {
                (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) {
            (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - TextField
extension ProdutoRegisterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0,y:0), animated: false)
    }
    
}

//MARK: - Methods
extension ProdutoRegisterViewController {
  
    
    func isEdit() {
        if produto != nil {
            navItem.title = "Editar Produto"
            var txtAtualizar = "Atualizar"
            txtAtualizar = txtAtualizar.uppercased()
            
            btnSave.setTitle(txtAtualizar, for: UIControlState.normal)
            tfProdutoNome.text = produto!.nome
            imgProduto.image = produto!.image as! UIImage!
            tfEstadoCompra.text = produto!.estado?.nome
            tfPreco.text = produto!.preco.currency
            swIOF.isOn = produto!.iof
        }
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func cancel() {
        tfEstadoCompra.resignFirstResponder()
    }
    
    func done() {
        if dataSource.count > 0 {
            tfEstadoCompra.text = dataSource[pickerView.selectedRow(inComponent: 0)].nome
            estadoSelecionado = dataSource[pickerView.selectedRow(inComponent: 0)] as Estado
        }
        cancel()
    }
    
    func addPickerView() {
        tfEstadoCompra.inputView = pickerView
    }
    
    func addToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        toolBar.items = [btCancel,space,btDone]
        tfEstadoCompra.inputAccessoryView = toolBar
    }
    
    func saveProduct() {
        if validator() {
            do {
                try context.save()
                navigationController!.popViewController(animated: true)
            } catch {
                print("Error salvar Produto")
            }
        }
    }
    
    func loadEstados() {
        
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try dataSource = context.fetch(fetchRequest)
            print(dataSource.count)
            pickerView.reloadAllComponents()
        } catch {
            print("erro")
        }
    }
    
    func objProduto() {
        if produto == nil {
            produto = Produto(context: context)
        }
        produto!.nome = tfProdutoNome.text
        if let image = imgSelecionada {
            produto!.image = image
        }
        if let purchaseState = estadoSelecionado {
            produto!.estado = purchaseState
        }
        if tfPreco.text != "" {
            produto!.preco = Double(tfPreco.text!.replacingOccurrences(of: ",", with: "."))!
        }
        produto!.iof = swIOF.isOn
        produto!.estado = dataSource[pickerView.selectedRow(inComponent: 0)]
    }
    
    func stateValid() -> Bool {
        return true
    }
    
    func validate() -> (Bool,isDecimal: Bool) {
        if tfProdutoNome.text == "" {
            return (false,true)
        }
        if imgProduto.image == UIImage(named: "img-cad-placeholder") {
            return (false,true)
        }
        if tfEstadoCompra.text == "" {
            return (false,true)
        }
        if tfPreco.text == "" {
            return (false,true)
        } else {
            guard let _ = Double(tfPreco.text!.replacingOccurrences(of: ",", with: ".")) else {
                return (false,false)
            }
        }
        return (true,true)
    }
    
    func showAlert(isDecimal: Bool) {
        var message = "Todos os campos são devem estar completos! "
        
        
        if !isDecimal {
            message = "O campo preço está incorreto! corrija por favor!"
        }
        
        
        
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func validator() -> Bool {
        if !validate().0 || !validate().isDecimal {
            showAlert(isDecimal: validate().isDecimal)
            return false
        } else {
            objProduto()
            return true
        }
    }
}

extension ProdutoRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        imgProduto.image = smallImage
        imgSelecionada = smallImage
        
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - PickerView
extension ProdutoRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let item = dataSource[row].nome
        return item
    }
}

extension ProdutoRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

