import SwiftUI

struct PlayerView: View {
    @Binding var player: Player
    @State private var isEditingName = false
    @State private var isEditingFlag = false
    @State private var newName = ""
    @State private var newFlag = ""
    
    var body: some View {
        HStack {
            Text(player.flag)
                .font(.title)
                .onTapGesture {
                    isEditingFlag = true
                }
            Text(player.name)
                .onTapGesture {
                    isEditingName = true
                    newName = player.name
                }
        }
        .sheet(isPresented: $isEditingName) {
            VStack {
                TextField("Nombre del jugador", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Guardar") {
                    player.name = newName
                    isEditingName = false
                }
            }
        }
        .sheet(isPresented: $isEditingFlag) {
            VStack {
                TextField("Código de país de 2 letras (ej. es, ar, us)", text: $newFlag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Guardar") {
                    if newFlag.count == 2 {
                        player.flag = flagEmoji(from: newFlag)
                    }
                    isEditingFlag = false
                }
            }
        }
    }
    
    func flagEmoji(from countryCode: String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(player: .constant(Player(name: "Jugador 1", flag: "🇪🇸")))
    }
}