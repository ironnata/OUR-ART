//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = MyExhibitionViewModel()
        
    @State private var showDeleteAlert: Bool = false
    
    let exhibition: Exhibition
    let myExhibitionId: String?
    
    var isMyExhibition: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    Text("No Poster")
                        .frame(width: 300, height: 100, alignment: .center)
                        .font(.objectivityTitle2)
                }
                .padding(.vertical, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(exhibition.title ?? "n/a")
                        .font(.objectivityLargeTitle)
                        .padding(.bottom, 20)
                    
                    
                    if let dateFrom = exhibition.dateFrom,
                       let dateTo = exhibition.dateTo {
                        let dateFormatter = DateFormatter.localizedDateFormatter()
                        let formattedDateFrom = dateFormatter.string(from: dateFrom)
                        let formattedDateTo = dateFormatter.string(from: dateTo)
                        
                        InfoDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)")
                    }
                    
                    InfoDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "n/a")
                    
                    if let openingTimeFrom = exhibition.openingTimeFrom,
                       let openingTimeTo = exhibition.openingTimeTo {
                        let dateFormatter = DateFormatter.timeOnlyFormatter()
                        
                        let formattedOpeningTimeFrom = dateFormatter.string(from: openingTimeFrom)
                        let formattedOpeningTimeTo = dateFormatter.string(from: openingTimeTo)
                        
                        InfoDetailView(icon: "clock", text: "\(formattedOpeningTimeFrom) - \(formattedOpeningTimeTo)")
                    }
                    
                    InfoDetailView(icon: "eye.slash.circle", text: exhibition.closingDays ?? ["n/a"])
                    
                    InfoDetailView(icon: "person.crop.square", text: exhibition.artist ?? "n/a")
                    
                    Image(systemName: "doc.richtext")
                    
                    Text(exhibition.description ?? "n/a")
                        .multilineTextAlignment(.leading)
                        .font(.objectivityFootnote)
                }
                .padding(.horizontal)
            }
            .navigationTitle("\(exhibition.title ?? "")")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .onTapGesture {
                            dismiss()
                        }
                }
                
                if isMyExhibition {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "trash")
                            .imageScale(.large)
                            .onTapGesture {
                                showDeleteAlert = true
                            }
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Your Exhibhition will be completely deleted, Is it okay?"),
                    primaryButton: .default(Text("OK")) {
                        if let myExhibitionId = myExhibitionId {
                            viewModel.deleteMyExhibitions(myExhibitionId: myExhibitionId)
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            if let myExhibitionId = myExhibitionId {
                viewModel.loadMyExhibition(myExhibitionId: myExhibitionId)
            }
        }
        .viewBackground()
    }
}




#Preview {
    NavigationStack {
        ExhibitionDetailView(exhibition: Exhibition(id: "1"), myExhibitionId: "", isMyExhibition: true)
    }
}



struct InfoDetailView<T: CustomStringConvertible>: View {
    var icon: String
    var text: T
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                if let arrayText = text as? [String] {
                    // 배열일 경우 문자열로 조인
                    Text(arrayText.joined(separator: ", "))
                } else {
                    // 아닐 경우 문자열 그대로 출력
                    Text(String(describing: text))
                }
            }
            Divider()
        }
    }
}
