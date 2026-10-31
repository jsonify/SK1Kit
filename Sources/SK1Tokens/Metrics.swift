import Foundation

extension SK1 {
    /// Sizes, radii and spacing, in points.
    public enum Metrics {
        /// A key with a symbol only (the floating bars'): a 28 pt face on its 2 pt skirt.
        public static let keyHeight: CGFloat = 30
        /// A pop-up key.
        public static let popUpHeight: CGFloat = 26
        /// A toggle's row.
        public static let toggleHeight: CGFloat = 20
        /// A key's corner radius.
        public static let keyRadius: CGFloat = 6
        /// The skirt under a key.
        public static let keySkirt: CGFloat = 2
        /// A sunken tray holding rows (Settings' groups and sidebar).
        public static let wellRadius: CGFloat = 10
        /// A sunken tray holding keys: the key radius plus 3.
        public static let trayRadius: CGFloat = 9
        /// A floating bar's or card's chassis plate.
        public static let plateRadius: CGFloat = 14
        /// An LCD's bezel, and how far the glass sits inside it.
        public static let lcdRadius: CGFloat = 9
        public static let lcdInset: CGFloat = 4
        /// A small LCD chip.
        public static let chipRadius: CGFloat = 4
        /// A toggle's square, and its corner radius.
        public static let toggleSquare: CGFloat = 9
        public static let toggleSquareRadius: CGFloat = 2
        /// A settings row's least height, and the inset of its content from the tray's edge.
        public static let rowMinHeight: CGFloat = 40
        public static let rowInset: CGFloat = 14
        /// A caption over a tray of rows (Settings) to the tray.
        public static let captionToWell: CGFloat = 8
        /// Between groups of a pane.
        public static let groupSpacing: CGFloat = 22
        /// A pane's margin, and the sidebar's width.
        public static let paneMargin: CGFloat = 22
        public static let sidebarWidth: CGFloat = 200
        /// Between a key's symbol and its title.
        public static let iconGap: CGFloat = 5
    }
}
