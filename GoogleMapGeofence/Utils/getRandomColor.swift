import Foundation
import UIKit

///Mark:- Generate a random color for geofence fill
 func getRandomColor() -> UIColor {
    let colors: [UIColor] = [.blue, .green, .purple, .orange, .cyan, .magenta, .yellow, .red]
    return colors.randomElement() ?? .blue
}
