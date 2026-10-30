import AudioToolbox
import UIKit

enum SoundPlayer {
    static func playCorrect() {
        AudioServicesPlaySystemSound(1057)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func playIncorrect() {
        AudioServicesPlaySystemSound(1053)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func playFinish() {
        AudioServicesPlaySystemSound(1025)
    }
}
