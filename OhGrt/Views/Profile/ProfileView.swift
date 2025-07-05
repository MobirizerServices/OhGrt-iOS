//
//  OnboardingView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var presentSideMenu: Bool
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Header Section
                ZStack(alignment: .top) {
                    Image("statusHeader")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: UIScreen.main.bounds.height * 0.35)
                        .clipped()
                        .ignoresSafeArea()

                    VStack(spacing: 5) {
                        // HStack for menu button and title
                        HStack {
                            Button {
                                presentSideMenu.toggle()
                            } label: {
                                Image("menu")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                            Spacer()
                            Text("My Profile")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                            // To keep the title centered, add an invisible button of same size
                            Color.clear
                                .frame(width: 32, height: 32)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)

                        Spacer()
                            .frame(height: 20)

                        if let url = viewModel.profileImageURL {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Image("defaultProfile")
                                    .resizable()
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 4)
                        } else {
                            Image("defaultProfile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(radius: 4)
                        }

                        Spacer()
                            .frame(height: 10)

                        if let profile = viewModel.userProfile {
                            Text(profile.user.name ?? "No Name")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(profile.user.email)
                                .font(.headline)
                                .foregroundColor(.white)
                                .textSelection(.disabled)
                                .allowsHitTesting(false)
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Menu Items
                List {
                    HStack {
                        Image("proNotify")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: $viewModel.isNotificationsOn)
                            .labelsHidden()
                            .onChange(of: viewModel.isNotificationsOn) { _ in
                                viewModel.toggleNotifications()
                            }
                    }
                    .padding(.vertical, 8)

                    profileLinkRow(icon: "proContact", title: "Contact Support", url: "https://yourdomain.com/support")
                        .padding(.vertical, 8)
                    profileLinkRow(icon: "proTerms", title: "Terms and Conditions", url: "https://yourdomain.com/terms")
                        .padding(.vertical, 8)
                    profileLinkRow(icon: "proPolicy", title: "Privacy Policy", url: "https://yourdomain.com/privacy")
                        .padding(.vertical, 8)
                    profileLinkRow(icon: "proAbout", title: "About App", url: "https://yourdomain.com/about")
                        .padding(.vertical, 8)

                    // Add spacing before logout button
                    Spacer()
                        .frame(height: 30)
                        .listRowBackground(Color.clear)

                    // Logout Button
                    Button {
                        viewModel.logout()
                    } label: {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }

    private func profileLinkRow(icon: String, title: String, url: String) -> some View {
        Button {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        } label: {
            HStack {
                Image(icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(title)
                Spacer()
            }
        }
        .foregroundColor(.primary)
    }
}

struct SubscriptionsView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        List {
//            ForEach(viewModel.subscriptions) { subscription in
//                SubscriptionRow(subscription: subscription)
//            }
        }
        .onAppear {
//            viewModel.fetchSubscriptions()
        }
    }
}

struct PointsView: View {
    @StateObject private var viewModel = PointsViewModel()
    
    var body: some View {
        VStack {
//            if let points = viewModel.points {
//                Text("Total Points: \(points.totalPoints)")
//                Text("Available Points: \(points.availablePoints)")
//                
//                List(points.transactions) { transaction in
//                    TransactionRow(transaction: transaction)
//                }
//            }
        }
        .onAppear {
//            viewModel.fetchPoints()
//            viewModel.fetchPointsSummary()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(presentSideMenu: .constant(false))
    }
}

