import UIKit


class Camera: UIViewController, UINavigationControllerDelegate  {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageTake: UIImageView!
    @IBOutlet weak var GalleryButton: UIButton!
    @IBOutlet weak var TakeButton: UIButton!
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        if((imageTake.image) == nil){ saveButton.isEnabled = false
        }else{
            saveButton.isEnabled = true
        }
    }
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //Suppression de la photo prise
            imageTake.image = nil
            saveButton.isEnabled = false
        }
    }
    @IBAction func GotoGallery(_ sender: Any) {
        selectImageFrom(.photoLibrary)
    }
    //Action du bouton "Take a photo"
    @IBAction func takePhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            selectImageFrom(.photoLibrary)
            return
        }
        selectImageFrom(.camera)
    }
    //Prend une image depuis l'appareil photo (si acces permis) ou de la gallerie
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
        saveButton.isEnabled = true
    }

    //Action du bouton "Save"
    @IBAction func save(_ sender: AnyObject) {
        guard let selectedImage = imageTake.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    //On s'occupe uniquement d'enregistrer la photo
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            //Erreur d'enregistrement
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    //Affiche un message d'erreur de notre choix
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
 }

 extension Camera: UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
}
