//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI
import MapKit

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var myExhibitionVM = MyExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    @StateObject private var mapVM = MapViewModel()
    
    @State private var showDeleteAlert = false
    @State private var showEditView = false
    
    var myExhibitionId: String?
    let exhibition: Exhibition
    var isMyExhibition: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                // TEST용
//                Text(exhibition.id)
//                Text(viewModel.myExhibition?.id ?? "myID is nil")
                
                AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    Text("No Poster")
                        .frame(width: 240, height: 360, alignment: .center)
                        .font(.objectivityTitle2)
                }
                .padding(.vertical, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(exhibition.title ?? "n/a")
                        .font(.objectivityTitle)
                        .padding(.bottom, 20)
                    
                    InfoDetailView(icon: "person.crop.square", text: exhibition.artist ?? "n/a")
                    
                    
                    if let dateFrom = exhibition.dateFrom,
                       let dateTo = exhibition.dateTo {
                        let dateFormatter = DateFormatter.localizedDateFormatter()
                        let formattedDateFrom = dateFormatter.string(from: dateFrom)
                        let formattedDateTo = dateFormatter.string(from: dateTo)
                        
                        InfoDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)")
                    }
                    
                    if let openingTimeFrom = exhibition.openingTimeFrom,
                       let openingTimeTo = exhibition.openingTimeTo {
                        let dateFormatter = DateFormatter.timeOnlyFormatter()
                        
                        let formattedOpeningTimeFrom = dateFormatter.string(from: openingTimeFrom)
                        let formattedOpeningTimeTo = dateFormatter.string(from: openingTimeTo)
                        
                        InfoDetailView(icon: "clock", text: "\(formattedOpeningTimeFrom) - \(formattedOpeningTimeTo)")
                    }
                    
                    InfoDetailView(icon: "eye.slash.circle", text: exhibition.closingDays ?? ["n/a"])
                    
                    InfoDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "n/a").textSelection(.enabled)
                    
                    // 지도 표시
                    if let coordinate = mapVM.coordinate {
                        // 좌표를 기준으로 지역 설정
                        let region = MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                        )
                        
                        Map(initialPosition: .region(region)) {
                            Annotation("", coordinate: coordinate, anchor: .bottom) {
                                Image(systemName: "mappin.and.ellipse.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.accent)
                                    .symbolEffect(.pulse)
                            }
                        }
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        Divider()
                    }
                    
                    Image(systemName: "doc.richtext")
                    
                    Text(exhibition.description ?? "n/a")
                        .multilineTextAlignment(.leading)
                        .font(.objectivityCallout)
                }
                .padding(.horizontal)
            }
            .navigationTitle("\(exhibition.title ?? "")")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground()
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
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                            .onTapGesture {
                                showEditView = true
                            }
                    }
                    
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
                            myExhibitionVM.deleteMyExhibition(myExhibitionId: myExhibitionId)
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showEditView, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Task {
                        try await exhibitionVM.loadCurrentExhibition(id: exhibition.id)
                        print(exhibition.id)
                    }
                    
                }
            }) {
                EditMyExhibitionView(showEditView: $showEditView, exhibitionId: exhibition.id)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(exhibition.title ?? "")
                        .font(.objectivityBody)
                        .lineLimit(1)
                }
            }
        }
        .onAppear {
            if let myExhibitionId = myExhibitionId {
                myExhibitionVM.loadMyExhibition(myExhibitionId: myExhibitionId)
                Task {
                    try await exhibitionVM.loadCurrentExhibition(id: exhibition.id)
                    print(exhibition.id)
                }
            }
            mapVM.fetchCoordinates(for: exhibition.address)
        }
        .viewBackground()
    }
}


#Preview {
    NavigationStack {
        ExhibitionDetailView(exhibition: Exhibition(id: "1"), isMyExhibition: true)
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
