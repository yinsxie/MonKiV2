import SwiftUI

struct CreateDishView: View {
    @Environment(CreateDishViewModel.self) var viewModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            VStack(alignment: .center) {
                Spacer()
                ZStack {
                    Image("chef_monki")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 413)
                    
                    ZStack(alignment: .center) {
                        Image("speech_bubble")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 202)
                        
                        if true {
                            Image("food_speech_bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64)
                        } else {
                            Text("Yummy")
                                .font(.wendyOne(size: 36))
                                .foregroundStyle(.black)
                        }
                    }
                    .offset(x: 150, y: -100)
                }
                Spacer()
                
                ShoppingBagView()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear {
                if viewModel.cgImage == nil && !viewModel.checkCheckoutItems() {
                    viewModel.generate()
                }
            }
            
            DishImageView(viewModel: viewModel)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
}
