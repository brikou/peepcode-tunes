
albums = [
    {
        title: "Album A", artist: "Artist A", tracks: [
            { title: "Track A", url: "/music/Album A Track A.mp3" }
            { title: "Track B", url: "/music/Album A Track B.mp3" }
        ]
    }
    {
        title: "Album B", artist: "Artist B", tracks: [
            { title: "Track A", url: "/music/Album B Track A.mp3" }
            { title: "Track B", url: "/music/Album B Track B.mp3" }
        ]
    }
]

describe "TunesCtrl", ->
    it "should initialize the scope for the view", ->
        scope = angular.scope()
        xhr = scope.$service("$browser").xhr
        xhr.expectGET("albums.json").respond albums
        ctrlScope = scope.$new(TunesCtrl)

        expect(ctrlScope.player.playlist.length).toBe 0
        expect(ctrlScope.albums).toBeUndefined()

        xhr.flush()
        expect(ctrlScope.albums).toBe albums

describe "player service", ->

    beforeEach ->
        @audioMock =
            play: jasmine.createSpy("play")
            pause: jasmine.createSpy("pause")
            src: `undefined`
            addEventListener: jasmine.createSpy("addEventListener")

        @player = angular.service("player")(@audioMock)

    it "should initialize the player", ->
        expect(@player.playlist.length).toBe 0
        expect(@player.playing).toBe false
        expect(@player.current).toEqual
            album: 0
            track: 0

    it "should register an ended event listener on adio", ->
        expect(@audioMock.addEventListener).toHaveBeenCalled()

    describe "play", ->
        it "should not do anything if playlist is empty", ->
            @player.play()
            expect(@player.playing).toBe false
            expect(@audioMock.play).not.toHaveBeenCalled()

        it "should play the currently selected song", ->
            @player.playlist.add albums[0]
            @player.play()
            expect(@player.playing).toBe true
            expect(@audioMock.play).toHaveBeenCalled()
            expect(@audioMock.src).toBe "/music/Album A Track A.mp3"

        it "should resume playing a song after paused", ->
            @player.playlist.add albums[0]
            @player.play()
            @player.pause()
            @audioMock.play.reset()
            @audioMock.src = "test"
            @player.play()
            expect(@player.playing).toBe true
            expect(@audioMock.play).toHaveBeenCalled()
            expect(@audioMock.src).toBe "test"

    describe "pause", ->
        it "should not do anything if player is not playing", ->
            @player.pause()
            expect(@player.playing).toBe false
            expect(@audioMock.pause).not.toHaveBeenCalled()

        it "should pause the player when playing", ->
            @player.playlist.add albums[0]
            @player.play()
            expect(@player.playing).toBe true
            @player.pause()
            expect(@player.playing).toBe false
            expect(@audioMock.pause).toHaveBeenCalled()

    describe "reset", ->
        it "should stop currently playing song and reset the internal state", ->
            @player.playlist.add albums[0]
            @player.current.track = 1
            @player.play()
            expect(@player.playing).toBe true
            @player.reset()
            expect(@player.playing).toBe false
            expect(@audioMock.pause).toHaveBeenCalled()
            expect(@player.current).toEqual
                album: 0
                track: 0

    describe "next", ->
        it "should do nothing if playlist is empty", ->
            @player.next()
            expect(@player.current).toEqual
                album: 0
                track: 0

        it "should advance to the next song in the album", ->
            @player.playlist.add albums[0]
            @player.next()
            expect(@player.current).toEqual
                album: 0
                track: 1

        it "should wrap around when on last song and there is just one album in playlist", ->
            @player.playlist.add albums[0]
            @player.next()
            @player.next()
            expect(@player.current).toEqual
                album: 0
                track: 0

        it "should wrap around when on last song and there are multiple albums in playlist", ->
            @player.playlist.add albums[0]
            @player.playlist.add albums[1]
            @player.current.album = 1
            @player.current.track = 1
            @player.next()
            expect(@player.current).toEqual
                album: 0
                track: 0

        it "should start playing the next song if currently playing", ->
            @player.playlist.add albums[0]
            @player.play()
            @audioMock.play.reset()
            @player.next()
            expect(@player.playing).toBe true
            expect(@audioMock.play).toHaveBeenCalled()
            expect(@audioMock.src).toBe "/music/Album A Track B.mp3"

    describe "previous", ->
        it "should do nothing if playlist is empty", ->
            @player.previous()
            expect(@player.current).toEqual
                album: 0
                track: 0

        it "should move to the previous song in the album", ->
            @player.playlist.add albums[0]
            @player.next()
            @player.previous()
            expect(@player.current).toEqual
                album: 0
                track: 0

        it "should wrap around when on first song and there is just one album in playlist", ->
            @player.playlist.add albums[0]
            @player.previous()
            expect(@player.current).toEqual
                album: 0
                track: 1

        it "should wrap around when on first song and there are multiple albums in playlist", ->
            @player.playlist.add albums[0]
            @player.playlist.add albums[1]
            @player.previous()
            expect(@player.current).toEqual
                album: 1
                track: 1

        it "should start playing the next song if currently playing", ->
            @player.playlist.add albums[0]
            @player.play()
            @audioMock.play.reset()
            @player.previous()
            expect(@player.playing).toBe true
            expect(@audioMock.play).toHaveBeenCalled()
            expect(@audioMock.src).toBe "/music/Album A Track B.mp3"

    describe "playlist", ->
        it "should be a simple array", ->
            expect(@player.playlist.constructor).toBe [].constructor

        describe "add", ->
            it "should add an album to the playlist if it's not present there already", ->
                expect(@player.playlist.length).toBe 0

                @player.playlist.add albums[0]
                expect(@player.playlist.length).toBe 1

                @player.playlist.add albums[1]
                expect(@player.playlist.length).toBe 2

                @player.playlist.add albums[0]
                expect(@player.playlist.length).toBe 2

        describe "remove", ->
            it "should remove an album from the playlist if present", ->
                @player.playlist.add albums[0]
                @player.playlist.add albums[1]
                expect(@player.playlist.length).toBe 2

                @player.playlist.remove albums[0]
                expect(@player.playlist.length).toBe 1
                expect(@player.playlist[0].title).toBe "Album B"

                @player.playlist.remove albums[1]
                expect(@player.playlist.length).toBe 0

                @player.playlist.remove albums[0]
                expect(@player.playlist.length).toBe 0

describe "audio service", ->
    it "should create and return html5 audio element", ->
        audio = angular.service("audio")([ document ])
        expect(audio.nodeName).toBe "AUDIO"
