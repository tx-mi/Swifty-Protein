//
//  API.swift
//  Swifty Protein
//
//  Created by Morgane DUBUS on 6/27/19.
//  Copyright © 2019 Morgane DUBUS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

enum APIError:Error {
    case ligandNameDoesntExist(String)
}


func getCount(_ entityName: String) -> Int {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    do {
        let count = try context.count(for: fetchRequest)
        return count
    }
    catch let error {
        print(error)
    }
    return 0
}

func deleteAllEntities(_ entity:String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    fetchRequest.returnsObjectsAsFaults = false
    do {
        let results = try context.fetch(fetchRequest)
        for object in results {
            guard let objectData = object as? NSManagedObject else { continue }
            context.delete(objectData)
        }
    } catch let error {
        print("Detele all data in \(entity) error :", error)
    }
}

func fetchAllMolecules() -> [Molecules] {
    let request: NSFetchRequest<Molecules> = Molecules.fetchRequest()
    do {
        let molecules = try context.fetch(request)
        return molecules
    }
    catch let error {
        print("Error fetching molecules : ", error)
        return []
    }
}

func fetchMolecule(moleculeName: String) -> Molecules? {
    let request: NSFetchRequest<Molecules> = Molecules.fetchRequest()
    request.predicate = NSPredicate(format: "ligand_Id = %@", moleculeName)
    do {
        
        let molecule = try context.fetch(request)
        if (molecule.count == 0) {
            throw APIError.ligandNameDoesntExist("Ligand's name doesn't exist")
        }
        return molecule.first
    }
    catch let error {
        print(error)
        return nil
    }
}

func updateMolecule(molecule: Molecules, view: UIViewController) -> Molecules? {
    guard let ligand = molecule.ligand_Id else {
        print("unable to retrieve ligand ID"); return nil
    }
    guard let moleculePdb = parseHtml(ligand: ligand) else { alert(view: view, message: "Unable to parse molecule's data"); return nil}
    let pdbLines = moleculePdb.components(separatedBy: "\n").filter({$0 != ""})
    
    for line in pdbLines{
        let lineTmp = line.components(separatedBy: " ").filter({$0 != ""})
        
        if (lineTmp[0] == "ATOM"){
            createAtom(splitAtomLine: lineTmp, molecule: molecule)
        }
        else if (lineTmp[0] == "CONECT"){
            createLink(newLink: lineTmp, molecule: molecule)
        }
    }
    do {
        try context.save()
        return molecule
    } catch let error{
        print(error)
    }
    return nil
}


func parseHtml(ligand: String) -> String? {
    let url = URL(string: "https://files.rcsb.org/ligands/view/" + ligand + "_ideal.pdb")
    do{
        let richText = try String(contentsOf: url!)
        return richText
    }catch let error{
        print(error)
    }
    return nil
}

func createAtom(splitAtomLine: [String], molecule : Molecules){
    let atom = Atoms(context: context)
    
    atom.type = splitAtomLine[11]
    atom.atom_Id = Int16(splitAtomLine[1])!
    atom.name = splitAtomLine[2]
    atom.coor_X = Float(splitAtomLine[6])!
    atom.coor_Y = Float(splitAtomLine[7])!
    atom.coor_Z = Float(splitAtomLine[8])!
    
    molecule.addToAtom(atom)
}

func createLink(newLink: [String], molecule : Molecules){
    /*
     newLink[1] est l atom de ref, les suivant sont ses connections.
     si l'id des suivant est superieur a celui de ref alors ont inscrit une nouvelle connection.
     sinon elle a logiquement deja été inscrite
     */
    
    let firstId = Int16(newLink[1])!
    for index in 2..<newLink.count{
        let link = Links(context: context)
        if (firstId < Int16(newLink[index])!){
            link.atome1_ID = firstId
            link.atome2_ID = Int16(newLink[index])!
            molecule.addToLinks(link)
        }
    }
}

