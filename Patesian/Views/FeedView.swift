import SwiftUI
import PhotosUI

class GameSettings: ObservableObject {
    @Published var score = UIImage?(nil)
}


struct feedView: View {
    @State var posts = [Posts]()
    @State var complete = [templatePosts]()
    @State var image = UIImage()
    @StateObject var settings = GameSettings()
    @State var groups = [Groups]()
    @State var sortedGroups = [String : Groups]()
    @State var createVisible = false
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var cachedPosts: FetchedResults<CachedPosts>

    func writePostCache(content: String, user: String, group: String, date: Date, image: UIImage?) async {
        let post = CachedPosts(context: managedObjectContext)
        post.content = content
        post.user = user
        post.group = group
        post.date = date
        post.postimage = image?.pngData()
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearAll() async {
        for x in cachedPosts {
            managedObjectContext.delete(x)
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                ScrollView{
                    VStack {
                        ForEach(posts.reversed(), id: \.self) { post in
                            if post.image == nil {
                                onePost(content: post.content, user: post.user, group: post.group, date: post.date, pfp: sortedGroups[post.group]?.image ?? UIImage(named: "patesCrest")!)
                                    .padding()
                            }
                            else {
                                imagePost(content: post.content, user: post.user, group: post.group, date: post.date, pfp: sortedGroups[post.group]?.image ?? UIImage(named: "patesCrest")!, image: post.image!)
                                    .environmentObject(settings)
                            }
                            Divider()
                        }
                    }
                }
                if settings.score != nil {
                    GeometryReader { geometry in
                        Image(uiImage: settings.score!)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .blur(radius: 20)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                    ZStack {
                        Image(uiImage: settings.score!)
                            .resizable()
                            .scaledToFit()
                        Button(action: {
                            DispatchQueue.main.async {
                                //withAnimation{
                                    settings.score = nil
                                //}
                            }
                            
                        }, label: {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrow.up.right.and.arrow.down.left.circle.fill")
                                        .padding()
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            
                        })
                    }
                    
                    .padding(.top, 6.0)
                    
                    
                    
                    
                    
                }
            }.task {
                do {
                    if cachedPosts.isEmpty {
                        print("empty")
                        try await posts = resolvePostTemplate()
                        try await groups = groupsGet()
                        sortedGroups = sortGroups(groups)
                        await clearAll()
                        for x in posts {
                            await writePostCache(content: x.content, user: x.user, group: x.group, date: x.date, image: x.image)
                        }
                    }
                    else {
                        for x in cachedPosts {
                            if let currentimage = x.postimage {
                                posts.append(Posts(user: x.user!, group: x.group!, title: nil, content: x.content!, image: UIImage(data: currentimage), date: x.date!))
                            }
                            else {
                                posts.append(Posts(user: x.user!, group: x.group!, title: nil, content: x.content!, image: nil, date: x.date!))
                            }
                            
                        }
                        
                    }
                    
                    print(sortedGroups)
                    print(posts)
                }
                catch {
                    print(error)
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        createVisible.toggle()
                    }, label: {Image(uiImage: UIImage(systemName: "plus")!)})
                }
            }
            .popover(isPresented: $createVisible, content: {
                NavigationStack{
                    createPost().navigationTitle("Create Post")
                }
                
                Button("Quit"){
                    createVisible.toggle()
                }
            })
            .refreshable(action: {
                Task {
                    do {
                        try await posts = resolvePostTemplate()
                        try await groups = groupsGet()
                        sortedGroups = sortGroups(groups)
                        await clearAll()
                        for x in posts {
                            await writePostCache(content: x.content, user: x.user, group: x.group, date: x.date, image: x.image)
                        }
                        
                        print(sortedGroups)
                        print(posts)
                    }
                    catch {
                        print(error)
                    }
                }
            })
        }
    }
        
}
