//
//  ProteinListViewController.swift
//  Swifty Protein
//
//  Created by Morgane on 18/06/2019.
//  Copyright © 2019 Morgane DUBUS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProteinListViewController:UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ligands = [String]()
    var searchedLigands = [String]()
    var selectedMolecule: String = ""
    var moleculeToPass: Molecules = Molecules()
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.allowsSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (ligands.count == 0) {
            
            self.tableView.separatorStyle = .none
            
            let spinnerView = SpinnerView.init(frame: view.frame)
            spinnerView.startSpinning()
            view.addSubview(spinnerView)
            
            DispatchQueue.main.async {
                OperationQueue.main.addOperation() {
//                    deleteAllEntities("Molecules")
                    let count = getCount("Molecules")
                    if (count == 0) {
                        self.loadProteinsIntoCoreData()
                    } else {
                        let molecules = fetchAllMolecules()
                        for molecule in molecules {
                            self.ligands.append(molecule.ligand_Id!)
                        }
                    }
                    
                    self.tableView.separatorStyle = .singleLine
                    self.searchBar.isHidden = false
                    self.tableView.reloadData()
                    spinnerView.stopSpinning()
                    spinnerView.removeFromSuperview()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadProteinsIntoCoreData() {
        let data = loadLigandsFile()
        for d in data {
            let molecule = Molecules(context: context)
            molecule.ligand_Id = d
            do {
                try context.save()
            } catch let error{
                print(error)
            }
        }
    }
    
    func loadLigandsFile() -> [String]{
        if let filepath = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let data = contents.components(separatedBy: "\n").filter({ $0 != ""})
                ligands = data
                return data
            } catch {
                print("Error : 'ligands.txt' couldn't be loaded")
            }
        } else {
            print("Error : 'ligands.txt.' wasn't found")
        }
        return []
    }
}

extension ProteinListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.text?.isEmpty == false ? searchedLigands.count : ligands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProteinTableViewCell
        cell.ligand = searchBar.text?.isEmpty == false ? searchedLigands[indexPath.row] : ligands[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        selectedMolecule = searchBar.text?.isEmpty == false ? searchedLigands[indexPath.row] : ligands[indexPath.row]
        
        guard let fetchedMolecule = fetchMolecule(moleculeName: selectedMolecule) else {
            alert(view:self, message: "Error trying to fetch molecule \(selectedMolecule)");
            return
        }
        
        let moleculeAtoms = fetchedMolecule.atom?.allObjects as! [Atoms]
        if (moleculeAtoms.count > 0) {
            print("getting existing molecule")
            moleculeToPass = fetchedMolecule
        }
        else {
            print("creating new molecule")
            guard let molecule:Molecules = updateMolecule(molecule: fetchedMolecule, view: self) else {
                alert(view: self, message: "unable to update molecule in core data") ;
                return
            }
            moleculeToPass = molecule
        }
        let count = getCount("Molecules")
        print("\(count) molecules in Core Data")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.performSegue(withIdentifier: "tapedCellSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tapedCellSegue") {
            let viewController = segue.destination as! ProteinViewController
            viewController.molecule = moleculeToPass
            viewController.navigationItemBar.title = moleculeToPass.ligand_Id
        }
    }
}


extension ProteinListViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedLigands = ligands.filter({$0.lowercased().contains(searchText.lowercased())})
        tableView.reloadData()
    }
}
