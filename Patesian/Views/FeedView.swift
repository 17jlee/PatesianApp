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
                            withAnimation(.linear(duration: 0.2)){
                                settings.score = nil
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
                    try await posts = resolvePostTemplate()
                    try await groups = groupsGet()
                    sortedGroups = sortGroups(groups)
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
