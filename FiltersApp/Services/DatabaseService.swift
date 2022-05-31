//
//  FirebaseService.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.05.22.
//

import Foundation
import Firebase

protocol DatabaseServiceProtocol: AnyObject{
    func downloadAll(onCompletion: @escaping ([ImageItem]?) -> Void)
    func upload(imageData: Data?, size: (width: Float, height: Float))
}

final class FirebaseService: DatabaseServiceProtocol{
    
    private var db: Database {
        return Database.database(url: FirebaseConstants.databaseUrl)
    }
    private var ref: DatabaseReference{
        return db.reference(withPath: FirebaseConstants.pathToImageItems)
    }
    private var refObservers: [DatabaseHandle] = []
    
    static var shared: DatabaseServiceProtocol = {
        return FirebaseService()
    }()
    
    private init(){}
    
    func downloadAll(onCompletion: @escaping ([ImageItem]?) -> Void){
        let completed = self.ref.observe(.value, with: { snapshot in
            var newItems: [ImageItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let imageItem = ImageItem(snapshot: snapshot) {
                    newItems.append(imageItem)
                }
            }
            onCompletion(newItems)
        })
        self.refObservers.append(completed)
    }
    
    func upload(imageData: Data?, size: (width: Float, height: Float)){
        let storageRef = Storage.storage().reference().child(FirebaseConstants.pathToImages).child("image\(UUID().uuidString).png")
        if let imageData = imageData{
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {return}
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print(error)
                    } else {
                        guard let url = url?.absoluteString else {return}
                        Database
                            .database(url: FirebaseConstants.databaseUrl)
                            .reference(withPath: FirebaseConstants.pathToImageItems)
                            .child(UUID().uuidString)
                            .setValue(ImageItem(url: url, width: Int16(size.width), height: Int16(size.height)).toAnyObject())
                    }
                }
            })
        }
    }
    
    //MARK: call fillInDB() to fill in database with initial data
//    private func fillInDB(){
//        let imageURLsWithSize = [
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage88220680-5BD0-4CA1-AD03-9C97BEA85ADA.png?alt=media&token=c050ff0b-0d31-4311-9692-fa2922fda020", 638, 638],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2FimageAC61DC7F-7A7D-487B-9A97-C5F769D85209.png?alt=media&token=188c143f-8a7c-4405-9abc-4f9c0cf37f4e", 1170, 1170],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage97CFFE9F-B035-4566-B04C-D147A16DE867.png?alt=media&token=d6a9ccf7-a58d-4810-a596-ddb09ab9b7e4", 600, 600],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage50218DFF-4305-4E83-992E-7B5A178EF504.png?alt=media&token=4a5d7f8b-daa0-4baf-81e6-9e1172483b4a", 1200, 748],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage61685920-505D-4D05-9458-42409742E50C.png?alt=media&token=4f044fd2-b929-484e-aa64-ae90d99d11ba", 2560, 1707],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2FimageFF198FAB-E6FB-473E-9A77-DE1F680E08FB.png?alt=media&token=02c64472-253e-46a4-be8c-1242dba8762f", 1092, 1640],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage2A720664-D3C3-42BA-9F5B-7E679DB7D357.png?alt=media&token=9d5ff7b8-d440-4e92-b18a-6184078cab22", 421, 236],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2FimageFBF874E9-A501-4A23-96D8-1549A1751116.png?alt=media&token=f439dcf3-eb70-4ffc-ac5e-fc7d1bf502eb", 638, 424],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2Fimage4E84F5FE-E52B-4DA1-BC6B-0599C4330981.png?alt=media&token=aa1b8dcd-d143-4df5-a649-465cc58eab80", 622, 964],
//            ["https://firebasestorage.googleapis.com:443/v0/b/filtersapp-d0e43.appspot.com/o/images%2FimageB868E477-E13F-4775-8F37-825408D9327A.png?alt=media&token=8e1e950e-ccbf-448a-b9fa-ed455043a03e", 2109, 1406],
//            ["https://carsweek.ru/upload/iblock/bda/bda7e2beb0c69851cdc0dea4dd612b50.jpg", 1200, 799],
//            ["https://a.d-cd.net/4ee2w/960.jpg", 960, 540],
//            ["https://cdn.pixabay.com/photo/2021/08/25/20/42/field-6574455__480.jpg", 721, 480],
//            ["https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&w=1000&q=80", 1000, 1498],
//            ["https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1000&q=80", 1000, 1250],
//            ["https://media.istockphoto.com/photos/very-closeup-view-of-amazing-domestic-pet-in-mirror-round-fashion-is-picture-id1281804798?b=1&k=20&m=1281804798&s=170667a&w=0&h=HIWbeaP_cQSngCz7l9t3xwyE2eyzVgIy3K6xIqPhJQA=", 509, 339],
//            ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8Dui-CG5_VcIxTHxks0tTiME_1rIvYeIfMA&usqp=CAU", 194, 259],
//            ["https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F5faad4255239c9448d6c7bcd%2F0x0.jpg", 1200, 900],
//            ["https://sun9-62.userapi.com/impf/c854320/v854320580/35a46/SWIQ1iW81nw.jpg?size=807x535&quality=96&sign=4c6e3859443348636c530a514e8e07a4&type=album", 807, 535]
//        ]
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else {return}
//            imageURLsWithSize.forEach{img in
//                let url = img[0] as! String
//                let width = img[1] as! Int16
//                let height = img[2] as! Int16
//                self.ref.child(UUID().uuidString).setValue(ImageItem(url: url, width: width, height: height).toAnyObject())
//            }
//        }
//    }
}

extension FirebaseService: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
