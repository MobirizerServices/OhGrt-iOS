//
//  SubscriptionView.swift
//  OhGrt
//
//  Created by Narendra on 06/05/25.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack(alignment: .topLeading) {
                Image("videoHeaderBG")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 130)
                    .clipped()
                
                Button(action: {
                    // Back button action (e.g., pop navigation)
                }) {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 100)
                        .padding(.top, 70)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("Subscription")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 70)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.clear)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose the perfect plan for your needs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(width: UIScreen.main.bounds.width)


                    VStack(alignment: .leading, spacing: 6) {
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("You can cancel your subscription anytime from the settings.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                    .frame(width: UIScreen.main.bounds.width)
                }
            }

        }
        .ignoresSafeArea(edges: .top)
    }
}

struct SubscriptionCard: View {
    let plan: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.subTitle)
                            .font(.headline)
                        if plan.isPopular {
                            Text("Popular")
                                .font(.caption)
                                .padding(4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }

                    Text(plan.subDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing) {
                }
            }

            ForEach(plan.features, id: \.self) { feature in
                HStack(spacing: 8) {
                    Image("sCheck")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text(feature)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }

            Button(action: {
                // handle choose plan
            }) {
                if plan.isPopular {
                    Image("btn")
                        .resizable()
                        .frame(height: 44)
                        .overlay(Text("Choose Plan")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                        )
                } else {
                    Text("Choose Plan")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}


struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}

