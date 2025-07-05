//
//  DashboardView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI

struct DashboardView: View {
    
//    @StateObject private var viewModel = DashboardViewModel()
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack{
            VStack{
                HStack {
//                    Button{
//                        presentSideMenu.toggle()
//                    } label: {
//                        Image("menu")
//                            .resizable()
//                            .frame(width: 50, height: 32)
////                            .background(.red)
//                    }
//                    Spacer()
                    
                }
                .padding(.horizontal, 10)
                
                TabView(selection: $selectedTab) {
                    HomeView(presentSideMenu: $presentSideMenu)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    
                    VideoView(presentSideMenu: $presentSideMenu)
                        .tabItem {
                            Label("Video", image: selectedSideMenuTab == 1 ? "Video_fill" : "Video")
                        }
                        .tag(1)
                    
                    ProfileView(presentSideMenu: $presentSideMenu)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(2)
                }
            }
            
             SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu)))
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
