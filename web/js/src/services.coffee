
angular.service "player", (audio) ->

    class Player
        constructor: ->
            @playing = false
            @reset()

            @albums = []

            @albums.add = (album) =>
                return unless angular.Array.indexOf(@albums, album) is -1
                @albums.push album

            @albums.remove = (album) =>
                @reset() if angular.Array.indexOf(@albums, album) is @current.album
                angular.Array.remove @albums, album

        reset: ->
            @pause()
            @current = { album: 0, track: 0}

        play: (track, album) ->
            return unless @albums.length
            @current.track = track if track?
            @current.album = album if album?
            audio.src = @albums[@current.album].tracks[@current.track].url unless @paused
            audio.play()
            @playing = true
            @paused = false

        pause: ->
            if @playing
                audio.pause()
                @playing = false
                @paused = true

        next: ->
            return unless @albums.length
            @paused = false
            if @albums[@current.album].tracks.length > (@current.track + 1)
                @current.track++
            else
                @current.track = 0
                @current.album = (@current.album + 1) % @albums.length
            @play() if @playing

        previous: ->
            return unless @albums.length
            @paused = false
            if @current.track > 0
                @current.track--
            else
                @current.album = (@current.album - 1 + @albums.length) % @albums.length
                @current.track = @albums[@current.album].tracks.length - 1
            @play() if @playing

    player = new Player()

    audio.addEventListener "ended", (=>
        @$apply player.next
    ), false

    player

# ============================================================================

angular.service "audio", ($document) ->
    $document[0].createElement("audio")
