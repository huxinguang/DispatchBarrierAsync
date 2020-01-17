//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


struct Course: Decodable {
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let number_of_lessons: Int?
}

struct WebsiteDescription: Decodable{
    let name: String?
    let description: String?
    let courses: [Course]?
}

private let course_url = "https://api.letsbuildthatapp.com/jsondecodable/course"
private let courses_url = "https://api.letsbuildthatapp.com/jsondecodable/courses"
private let website_description_url = "https://api.letsbuildthatapp.com/jsondecodable/website_description"

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "AsynchronousTasksInOrder"
        label.textColor = .black
        view.addSubview(label)
        NSLayoutConstraint.activate([NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // https://stackoverflow.com/questions/45682622/swift-execute-asynchronous-tasks-in-order
        
        let serialQueue = DispatchQueue(label: "serialQueue")
        let group = DispatchGroup()
        group.enter()
        serialQueue.async {
            guard let url = URL(string: course_url) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                print("task1 completed")
                guard let data = data else {
                    group.leave()
                    return
                }
                do {
                    let course = try JSONDecoder().decode(Course.self, from: data)
                    print(course.name ?? "")
                } catch let error {
                    print(error.localizedDescription)
                }
                group.leave()
            }.resume()
        }
        
        serialQueue.async {
            group.wait()
            group.enter()
            guard let url = URL(string: courses_url) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                print("task2 completed")
                guard let data = data else {
                    group.leave()
                    return
                }
                do {
                    let courses = try JSONDecoder().decode([Course].self, from: data)
                    print(courses[0].name ?? "")
                } catch let error {
                    print(error.localizedDescription)
                }
                group.leave()
            }.resume()
        }
        
        serialQueue.async {
            group.wait()
            group.enter()
            guard let url = URL(string: website_description_url) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                print("task3 completed")
                guard let data = data else {
                    group.leave()
                    return
                }
                do {
                    let websiteDescription = try JSONDecoder().decode(WebsiteDescription.self, from: data)
                    print(websiteDescription.name ?? "")
                } catch let error {
                    print(error.localizedDescription)
                }
                group.leave()
            }.resume()
        }
        
        print("+++++++++")
        
    }
    
    
    
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
