import AVKit
import SwiftUI

final class PlayerViewModel: ObservableObject {
    let player: AVPlayer
    init(url: URL) {
        player = AVPlayer(url: url)
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func unload() {
        player.replaceCurrentItem(with: nil)
    }
}

public struct SplashPageView: View {

    @StateObject private var model = PlayerViewModel(
        url: Bundle.module.url(forResource: "waterdrop", withExtension: "mp4")!
    )

    public init() {
        
    }

    public var body: some View {
        VideoPlayer(player: model.player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                model.play()
            }
            .onDisappear {
                model.unload()
            }
    }
}

struct SplashPageView_Previews: PreviewProvider {
    static var previews: some View {
        SplashPageView()
    }
}
