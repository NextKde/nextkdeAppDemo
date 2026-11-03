import QtQuick

Item {
    id: root
    property bool filled: false
    property string name: "check"
    property color color: "white"
    property real size: 16
    property real strokeWidth: 2
    implicitWidth: size
    implicitHeight: size
    readonly property var paths: ({
        info: "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18 M12 16v-4 M12 8h.01",
        sliders: "M10 5H3 M12 19H3 M14 3v4 M16 17v4 M21 12h-9 M21 19h-5 M21 5h-7 M8 10v4 M8 12H3",
        calendar: "M4 5h16v16H4zM4 9h16M8 3v4M16 3v4",
        flag: "M5 21V4c4-3 9 3 14 0v10c-5 3-10-3-14 0",
        reminder: "M13 5h8 M13 12h8 M13 19h8 M3 17l2 2 4-4 M3 7l2 2 4-4",
        check: "M5 12l5 5L20 7",
        close: "M18 6 6 18 m6 6 12 12",
        chevron: "M6 9l6 6 6-6",
        chevronsUpDown: "M8 8l4-4 4 4M8 16l4 4 4-4",
        preview: "M7 17L17 7M8 7h9v9",
        theme: "M12 3l9 9-9 9-9-9zM8 12l4-4 4 4-4 4z",
        wallpaper: "M3 4h18v16H3zM3 16l5-5 4 4 3-3 6 5M16 8h.01",
        panel: "M3 5h18v14H3zM3 9h18M7 9v10",
        dock: "M3 13h18v7H3zM7 16v1M12 16v1M17 16v1",
        grid: "M3 3h6v6H3zM15 3h6v6h-6zM3 15h6v6H3zM15 15h6v6h-6z",
        keyboard: "M3 6h18v12H3zM7 10h.01M12 10h.01M17 10h.01M7 14h10",
        settings: "M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6L7 7M17 17l1.4 1.4M5.6 18.4L7 17M17 7l1.4-1.4",
        editRounded: "M12 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7 M18.375 2.625a1 1 0 0 1 3 3l-9.013 9.014a2 2 0 0 1-.853.505l-2.873.84a.5.5 0 0 1-.62-.62l.84-2.873a2 2 0 0 1 .506-.852z",
        trashRounded: "M5 6.8h14M9 6.8V4.9a1.4 1.4 0 0 1 1.4-1.4h3.2A1.4 1.4 0 0 1 15 4.9v1.9M6.5 6.8l.6 12a1.7 1.7 0 0 0 1.7 1.7h6.4a1.7 1.7 0 0 0 1.7-1.7l.6-12M10.2 10v7M13.8 10v7",
        refreshRounded: "M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8 M21 3v5h-5",
        trash: "M3 6h18M8 6V3h8v3M6 6l1 15h10l1-15M10 10v7M14 10v7",
        archive: "M3 4h18v4H3z M5 8v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8 M12 10v5 M9.5 12.5 12 15l2.5-2.5",
        envelope: "M3 5h18v14H3z M3 5l9 8 9-8",
        envelopeOpen: "M3 9.5 12 3l9 6.5V21H3z M3 9.5 12 16l9-6.5",
        arrows: "M8 3 4 7l4 4 M4 7h16 M16 21l4-4-4-4 M20 17H4",
        circle: "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8",
        contrast: "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 3v18M12 7h5M12 11h8M12 15h7",
        waves: "M3 8c3-4 6 4 9 0s6 4 9 0M3 16c3-4 6 4 9 0s6 4 9 0",
        copy: "M8 8h13v13H8zM16 8V3H3v13h5",
        home: "M3 10l9-7 9 7M5 9v12h14V9M10 21v-7h4v7",
        search: "M11 3a8 8 0 1 0 0 16 8 8 0 0 0 0-16 M21 21l-4.34-4.34",
        filter: "M10 20a1 1 0 0 0 .553.895l2 1A1 1 0 0 0 14 21v-7a2 2 0 0 1 .517-1.341L21.74 4.67A1 1 0 0 0 21 3H3a1 1 0 0 0-.742 1.67l7.225 7.989A2 2 0 0 1 10 14z",
        resize: "M4 10V4h6M20 14v6h-6M4 4l6 6M20 20l-6-6",
        undo: "M9 14 4 9l5-5 M4 9h10.5a5.5 5.5 0 0 1 5.5 5.5a5.5 5.5 0 0 1-5.5 5.5H11",
        bold: "M6 3h7a4.5 4.5 0 0 1 0 9H6zM6 12h8a4.5 4.5 0 0 1 0 9H6z",
        corners: "M4 12V8a4 4 0 0 1 4-4h4M12 20h4a4 4 0 0 0 4-4v-4",
        shadow: "M4 4h13v13H4zM8 20h12V8",
        minimize: "M4 6h16v12H4zM9 12l3 3 3-3M12 9v6",
        plus: "M12 4v16M4 12h16",
        music: "M9 18V5l11-2v13M9 9l11-2M9 18a3 3 0 1 1-3-3h3M20 16a3 3 0 1 1-3-3h3",
        album: "M4 3h16v18H4zM8 7h8M8 11h8M8 15h4",
        artist: "M12 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8M4 21v-2a8 8 0 0 1 16 0v2",
        mediaPrevious: "M11 5L1 12l10 7zM23 5L13 12l10 7z",
        mediaNext: "M1 5l10 7-10 7zM13 5l10 7-10 7z",
        mediaPlay: "M6 3l15 9-15 9z",
        mediaPause: "M5 3h5v18H5zM15 3h5v18h-5z",
        queueList: "M7 5h14M7 12h14M7 19h14M2 5h.01M2 12h.01M2 19h.01",
        play: "M8 4l12 8-12 8z",
        pause: "M7 4v16M17 4v16",
        previous: "M5 4v16M19 5L8 12l11 7z",
        next: "M19 4v16M5 5l11 7-11 7z",
        shuffle: "M3 6h3c5 0 7 12 12 12h3M17 14l4 4-4 4M3 18h3c2 0 4-3 5-6M14 8c1-1 2-2 4-2h3M17 2l4 4-4 4",
        repeat: "M4 7h15l-4-4M20 17H5l4 4M4 7v5M20 17v-5",
        queue: "M4 5h12M4 10h12M4 15h8M18 13v8M14 17h8",
        volume: "M3 9h4l5-4v14l-5-4H3zM16 8a6 6 0 0 1 0 8M19 5a10 10 0 0 1 0 14",
        folder: "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z",
        download: "M12 15V3 M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4 m7 10 5 5 5-5",
        back: "m15 18-6-6 6-6",
        forward: "m15 17 5-5-5-5 M4 18v-2a4 4 0 0 1 4-4h12",
        more: "M5 12h.01M12 12h.01M19 12h.01",
        radio: "M12 16a2 2 0 1 0 0 .01M8 13a6 6 0 0 1 8 0M5 10a10 10 0 0 1 14 0M2 7a14 14 0 0 1 20 0",
        sparkle: "M12 3l2.5 6.5L21 12l-6.5 2.5L12 21l-2.5-6.5L3 12l6.5-2.5z",
        heart: "M12 20L4 12a5 5 0 0 1 8-6 5 5 0 0 1 8 6z",
        panelLeft: "M3.5 5.5h17v13h-17z M9.5 5.5v13"
    })
    Image {
        anchors.fill: parent
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        readonly property string ink: 'rgb(' + Math.round(root.color.r * 255) + ',' + Math.round(root.color.g * 255) + ',' + Math.round(root.color.b * 255) + ')'
        source: "data:image/svg+xml;utf8," + encodeURIComponent(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="' + (root.filled ? ink : 'none')
            + '" fill-opacity="' + root.color.a + '" stroke="' + (root.filled ? 'none' : ink) + '" stroke-opacity="' + root.color.a
            + '" stroke-width="' + root.strokeWidth + '" stroke-linecap="round" stroke-linejoin="round" d="'
            + (root.paths[root.name] || root.paths.check) + '"/></svg>')
    }
}
