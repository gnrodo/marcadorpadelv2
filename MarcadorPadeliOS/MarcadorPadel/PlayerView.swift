import SwiftUI

struct PlayerView: View {
    @Binding var player: Player
    @State private var isEditingName = false
    @State private var newName = ""
    
    var body: some View {
        HStack {
            Text(player.flag)
                .font(.largeTitle)
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
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(player: .constant(Player(name: "Jugador 1", flag: "🇪🇸")))
    }
}