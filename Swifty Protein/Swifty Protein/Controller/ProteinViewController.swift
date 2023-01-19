import UIKit
import SceneKit
import Accelerate
import CoreData

class ProteinViewController: UIViewController {


    @IBOutlet weak var scnView: SCNView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!

    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var molecule: Molecules = Molecules()
    @IBOutlet weak var navigationItemBar: UINavigationItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupCamera()
        parseMolecule()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        scnView.addGestureRecognizer(tap)

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.white
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = SCNAntialiasingMode.multisampling4X
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        self.scnView.scene?.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        parseMolecule()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let location: CGPoint = (sender?.location(in: scnView))!
        let hits = self.scnView.hitTest(location, options: nil)
        if let tappedNode = hits.first?.node {
            setInfos(atomType: tappedNode.name!)
        }
    }

    func parseMolecule(){

        for atom in (molecule.atom?.allObjects) as! [Atoms]{
            drawOneSphere(atom: atom)
        }

        for link in (molecule.links?.allObjects) as! [Links]{
            drawOneLink(link: link)
        }
    }


    func searchAtom(id: Int16, atoms: [Atoms]) -> Atoms{
        for atom in atoms{
            if (atom.atom_Id == id){
                return atom
            }
        }
        return atoms[1]
    }

    func drawOneLink(link: Links){
        let atom1 = searchAtom(id: link.atome1_ID, atoms: (molecule.atom?.allObjects) as! [Atoms])
        let atom2 = searchAtom(id: link.atome2_ID, atoms: (molecule.atom?.allObjects) as! [Atoms])

        let pos1 = simd_float3(x: atom1.coor_X, y: atom1.coor_Y, z: atom1.coor_Z)
        let pos2 = simd_float3(x: atom2.coor_X, y: atom2.coor_Y, z: atom2.coor_Z)
        let yAxis = simd_float3(x:0, y:1, z:0)
        let diff = pos2 - pos1
        let norm = simd_normalize(diff)
        let dot = simd_dot(yAxis, norm)

        var geometry: SCNGeometry
        geometry = SCNCylinder(radius: 0.15, height: 1)
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.name = "Stick"

        if (abs(dot) < 0.999999)
        {
            let cross = simd_cross(yAxis, norm)
            let quaternion = simd_quatf(vector: simd_float4(x: cross.x, y: cross.y, z: cross.z, w: 1 + dot))
            geometryNode.simdOrientation = simd_normalize(quaternion)
        }

        geometryNode.simdPosition = diff / 2 + pos1
        geometryNode.simdScale = simd_float3(x: 1, y: simd_length(diff), z: 1)
        scnScene.rootNode.addChildNode(geometryNode)
    }

    func drawOneSphere(atom: Atoms){

        var geometry: SCNGeometry

        geometry = SCNSphere(radius: 0.4)
        if (segmentControl.selectedSegmentIndex == 0){
            geometry.firstMaterial?.diffuse.contents = getColor(atomType: atom.type!)
        }
        else{
            geometry.firstMaterial?.diffuse.contents = getJmolColor(atomType: atom.type!)
        }
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.name = atom.type!
        geometryNode.position = SCNVector3(x: atom.coor_X, y: atom.coor_Y, z: atom.coor_Z)
        scnScene.rootNode.addChildNode(geometryNode)
    }

    func setInfos(atomType: String){
        switch atomType{
        case "H":
            nameLabel.text = "Hydrogène"
            symbolLabel.text = "H"
            numLabel.text = "1"
            massLabel.text = "1"
        case "C":
            nameLabel.text = "Carbone"
                symbolLabel.text = "C"
                numLabel.text = "6"
                massLabel.text = "12.01"
        case "N":
            nameLabel.text = "Azote"
                symbolLabel.text = "N"
                numLabel.text = "7"
                massLabel.text = "14"
        case "O":
            nameLabel.text = "Oxygène"
                symbolLabel.text = "O"
                numLabel.text = "8"
                massLabel.text = "15.99"
        case "F":
            nameLabel.text = "Fluor"
                symbolLabel.text = "F"
                numLabel.text = "9"
                massLabel.text = "18.99"
        case "Cl":
            nameLabel.text = "Chlore"
            symbolLabel.text = "Cl"
            numLabel.text = "17"
            massLabel.text = "35.45"
        case "Br":
            nameLabel.text = "Brome"
                symbolLabel.text = "Br"
                numLabel.text = "35"
                massLabel.text = "79.90"
        case "I":
            nameLabel.text = "Iode"
                symbolLabel.text = "I"
                numLabel.text = "53"
                massLabel.text = "126.90"
        case "He":
            nameLabel.text = "Hélium"
                symbolLabel.text = "He"
                numLabel.text = "2"
                massLabel.text = "4.00"
        case "Ne":
            nameLabel.text = "Néon"
                symbolLabel.text = "Ne"
                numLabel.text = "10"
                massLabel.text = "20.18"
        case "Ar":
            nameLabel.text = "Argon"
                symbolLabel.text = "Ar"
                numLabel.text = "18"
                massLabel.text = "39.95"
        case "Xe":
            nameLabel.text = "Xénon"
                symbolLabel.text = "Xe"
                numLabel.text = "54"
                massLabel.text = "131.29"
        case "Kr":
            nameLabel.text = "Krypton"
                symbolLabel.text = "Kr"
                numLabel.text = "36"
                massLabel.text = "83.79"
        case "P":
            nameLabel.text = "Phosphore"
                symbolLabel.text = "P"
                numLabel.text = "15"
                massLabel.text = "30.97"
        case "S":
            nameLabel.text = "Soufre"
                symbolLabel.text = "S"
                numLabel.text = "16"
                massLabel.text = "32.06"
        case "B":
            nameLabel.text = "Bore"
                symbolLabel.text = "B"
                numLabel.text = "5"
                massLabel.text = "10.81"
        case "Li":
            nameLabel.text = "Lithium"
                symbolLabel.text = "Li"
            numLabel.text = "3"
                massLabel.text = "6.93"
        case "Na":
            nameLabel.text = "Sodium"
                symbolLabel.text = "Na"
                numLabel.text = "11"
                massLabel.text = "22.99"
        case "K":
            nameLabel.text = "Potassium"
                symbolLabel.text = "K"
                numLabel.text = "19"
                massLabel.text = "39.10"
        case "Rb":
            nameLabel.text = "Rubidium"
                symbolLabel.text = "Rb"
                numLabel.text = "37"
                massLabel.text = "85.47"
        case "Cs":
            nameLabel.text = "Césium"
                symbolLabel.text = "Cs"
                numLabel.text = "55"
                massLabel.text = "132.91"
        case "Fr":
            nameLabel.text = "Francium"
                symbolLabel.text = "Fr"
                numLabel.text = "87"
                massLabel.text = "223"
        case "Be":
            nameLabel.text = "Béryllium"
                symbolLabel.text = "Be"
                numLabel.text = "4"
                massLabel.text = "9.01"
        case "Mg":
            nameLabel.text = "Magnésium"
                symbolLabel.text = "Mg"
                numLabel.text = "12"
                massLabel.text = "24.30"
        case "Ca":
            nameLabel.text = "Calcium"
                symbolLabel.text = "Ca"
                numLabel.text = "20"
                massLabel.text = "40.08"
        case "Sr":
            nameLabel.text = "Strontium"
                symbolLabel.text = "Sr"
                numLabel.text = "38"
                massLabel.text = "87.62"
        case "Ba":
            nameLabel.text = "Baryum"
                symbolLabel.text = "Ba"
                numLabel.text = "56"
                massLabel.text = "137.32"
        case "Ra":
            nameLabel.text = "Radium"
                symbolLabel.text = "Ra"
                numLabel.text = "88"
                massLabel.text = "226"
        case "Ti":
            nameLabel.text = "Titane"
                symbolLabel.text = "Ti"
                numLabel.text = "22"
                massLabel.text = "47.87"
        case "Fe":
            nameLabel.text = "Fer"
                symbolLabel.text = "Fe"
                numLabel.text = "26"
                massLabel.text = "55.85"
        default:
            nameLabel.text = nameLabel.text
                symbolLabel.text = symbolLabel.text
                numLabel.text = numLabel.text
                massLabel.text = massLabel.text
        }
    }

    func getColor(atomType: String) -> UIColor{
        switch atomType{
        case "H":
            return UIColor.white
        case "C":
            return UIColor.black
        case "N":
            return UIColor(red:0.13, green:0.00, blue:1.00, alpha:1.0)
        case "O":
            return UIColor.red
        case "F", "Cl":
            return UIColor.green
        case "Br":
            return UIColor(red:0.59, green:0.10, blue:0.01, alpha:1.0)
        case "I":
            return UIColor(red:0.39, green:0.00, blue:0.73, alpha:1.0)
        case "He", "Ne", "Ar", "Xe", "Kr":
            return UIColor(red:0.17, green:1.00, blue:1.00, alpha:1.0)
        case "P":
            return UIColor.orange
        case "S":
            return UIColor.yellow
        case "B":
            return UIColor(red:0.99, green:0.66, blue:0.51, alpha:1.0)
        case "Li", "Na", "K", "Rb", "Cs", "Fr":
            return UIColor(red:0.46, green:0.00, blue:1.00, alpha:1.0)
        case "Be", "Mg", "Ca", "Sr", "Ba", "Ra":
            return UIColor(red:0.06, green:0.48, blue:0.00, alpha:1.0)
        case "Ti":
            return UIColor.gray
        case "Fe":
            return UIColor(red:0.86, green:0.46, blue:0.02, alpha:1.0)
        default:
            return UIColor(red:0.86, green:0.42, blue:1.00, alpha:1.0)
        }
    }
    
    func getJmolColor(atomType: String) -> UIColor{
        switch atomType{
        case "H":
            return UIColor.white
        case "C":
            return UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.0)
        case "N":
            return UIColor(red:0.18, green:0.25, blue:0.97, alpha:1.0)
        case "O":
            return UIColor(red:0.99, green:0.00, blue:0.07, alpha:1.0)
        case "F":
            return UIColor(red:0.58, green:0.89, blue:0.32, alpha:1.0)
        case "Cl":
            return UIColor(red:0.21, green:0.96, blue:0.13, alpha:1.0)
        case "Br":
            return UIColor(red:0.64, green:0.13, blue:0.16, alpha:1.0)
        case "I":
            return UIColor(red:0.57, green:0.00, blue:0.58, alpha:1.0)
        case "He":
            return UIColor(red:0.85, green:1.00, blue:1.00, alpha:1.0)
        case "Ne":
            return UIColor(red:0.71, green:0.89, blue:0.96, alpha:1.0)
        case "Ar":
            return UIColor(red:0.51, green:0.82, blue:0.89, alpha:1.0)
        case "Xe":
            return UIColor(red:0.27, green:0.62, blue:0.69, alpha:1.0)
        case "Kr":
            return UIColor(red:0.38, green:0.72, blue:0.82, alpha:1.0)
        case "P":
            return UIColor(red:0.99, green:0.49, blue:0.03, alpha:1.0)
        case "S":
            return UIColor(red:1.00, green:1.00, blue:0.20, alpha:1.0)
        case "B":
            return UIColor(red:0.99, green:0.70, blue:0.71, alpha:1.0)
        case "Li":
            return UIColor(red:0.79, green:0.46, blue:1.00, alpha:1.0)
        case "Na":
            return UIColor(red:0.66, green:0.30, blue:0.95, alpha:1.0)
        case "K":
            return UIColor(red:0.55, green:0.18, blue:0.83, alpha:1.0)
        case "Rb":
            return UIColor(red:0.44, green:0.11, blue:0.69, alpha:1.0)
        case "Cs":
            return UIColor(red:0.34, green:0.00, blue:0.56, alpha:1.0)
        case "Fr":
            return UIColor(red:0.25, green:0.00, blue:0.40, alpha:1.0)
        case "Be":
            return UIColor(red:0.77, green:1.00, blue:0.03, alpha:1.0)
        case "Mg":
            return UIColor(red:0.56, green:1.00, blue:0.03, alpha:1.0)
        case "Ca":
            return UIColor(red:0.30, green:1.00, blue:0.02, alpha:1.0)
        case "Sr":
            return UIColor(red:0.18, green:1.00, blue:0.02, alpha:1.0)
        case "Ba":
            return UIColor(red:0.13, green:0.81, blue:0.01, alpha:1.0)
        case "Ra":
            return UIColor(red:0.07, green:0.50, blue:0.00, alpha:1.0)
        case "Ti":
            return UIColor(red:0.75, green:0.76, blue:0.78, alpha:1.0)
        case "Fe":
            return UIColor(red:0.87, green:0.39, blue:0.20, alpha:1.0)
        default:
            return UIColor(red:0.99, green:0.00, blue:0.58, alpha:1.0)
        }
    }


    @IBAction func share(_ sender: UIButton) {
        var wholeImage : UIImage?
        DispatchQueue.main.async {
            UIGraphicsBeginImageContext(self.view.bounds.size)
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
            wholeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let image = wholeImage {
                let objectsToShare = [image]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }


}


