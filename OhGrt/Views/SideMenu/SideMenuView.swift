//
//  SideMenuView.swift
//  OhGrt
//
//  Created by Narendra on 28/04/25.
//

import SwiftUI

enum SideMenuRowType: Int, CaseIterable {
    case rate = 0
    case share
    case about
    case update
    case more
    
    var title: String {
        switch self {
        case .rate:
            return "Rate"
        case .share:
            return "Share"
        case .about:
            return "About us"
        case .update:
            return "Update"
        case .more:
            return "More AI App"
        }
    }
    
    var iconName: String {
        switch self {
        case .rate:
            return "rate"
        case .share:
            return "share"
        case .about:
            return "about"
        case .update:
            return "update"
        case .more:
            return "more"
        }
    }
    
    var section: MenuSection {
        switch self {
        case .rate, .share:
            return .main
        case .about:
            return .preferences
        case .update, .more:
            return .support
        }
    }
}

enum MenuSection: String {
    case main = "Main Menu"
    case preferences = "Preferences"
    case support = "Support"
    
    static var allSections: [MenuSection] = [.main, .preferences, .support]
}

struct SideMenuView: View {
    @Binding var selectedSideMenuTab: Int
    @Binding var presentSideMenu: Bool
    @State private var showShareSheet = false
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: 270)
                    .shadow(color: .purple.opacity(0.1), radius: 5, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    ProfileImageView()
                        .frame(height: 140)
                        .padding(.bottom, 30)
                    
                    ForEach(MenuSection.allSections, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(section.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                            
                            let sectionItems = SideMenuRowType.allCases.filter { $0.section == section }
                            ForEach(sectionItems, id: \.self) { row in
                                RowView(isSelected: selectedSideMenuTab == row.rawValue,
                                       imageName: row.iconName,
                                       title: row.title) {
                                    selectedSideMenuTab = row.rawValue
                                    handleMenuAction(row)
                                    presentSideMenu.toggle()
                                }
                            }
                            
                            if section != .support {
                                Divider()
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 100)
                .frame(width: 270)
                .background(Color.white)
            }
            
            Spacer()
        }
        .background(.clear)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["Check out this awesome app: OhGrt"])
        }
    }
    
    func ProfileImageView() -> some View {
        VStack(alignment: .center) {
            HStack{
                Spacer()
                Image("menuHead")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 250)
//                Spacer()
            }
        }
    }
    
    func RowView(isSelected: Bool, imageName: String, title: String, hideDivider: Bool = false, action: @escaping (()->())) -> some View{
        Button{
            action()
        } label: {
            VStack(alignment: .leading){
                HStack(spacing: 20){
                    Rectangle()
                        .fill(isSelected ? .purple : .white)
                        .frame(width: 5)
                    
                    ZStack{
                        Image(imageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(isSelected ? .black : .gray)
                            .frame(width: 26, height: 26)
                    }
                    .frame(width: 30, height: 30)
                    Text(title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isSelected ? .black : .black)
                    Spacer()
                }
            }
        }
        .frame(height: 50)
        .background(
            LinearGradient(colors: [isSelected ? .purple.opacity(0.5) : .white, .white], startPoint: .leading, endPoint: .trailing)
        )
    }
    
    func handleMenuAction(_ type: SideMenuRowType) {
        switch type {
        case .rate:
            if let url = URL(string: "itms-apps://itunes.apple.com/app/YOUR-APP-ID") {
                UIApplication.shared.open(url)
            }
        case .share:
            showShareSheet = true
        case .about:
            // Navigate to About screen
            break
        case .update:
            if let url = URL(string: "itms-apps://itunes.apple.com/app/YOUR-APP-ID") {
                UIApplication.shared.open(url)
            }
        case .more:
            if let url = URL(string: "https://apps.apple.com/developer/YOUR-DEVELOPER-ID") {
                UIApplication.shared.open(url)
            }
        }
    }
}

// Helper view for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

//https://medium.com/geekculture/side-menu-in-ios-swiftui-9fe1b69fc487
