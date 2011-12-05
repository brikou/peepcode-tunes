
TunesCtrl = ($xhr, @player) ->
    $xhr "GET", "albums.json", (code, response) =>
        @albums = response

"use strict"

TunesCtrl.$inject = [ "$xhr", "player" ]

angular.service "player", (audio) ->

    playlist = []
    paused = false
    current =
        album: 0
        track: 0

    player =
        playlist: playlist
        current: current
        playing: false

        play: (track, album) ->
            return unless @playlist.length
            @current.track = track if angular.isDefined(track)
            @current.album = album if angular.isDefined(album)
            audio.src = @playlist[@current.album].tracks[@current.track].url unless paused
            audio.play()
            @playing = true
            paused = false

        pause: ->
            if @playing
                audio.pause()
                @playing = false
                paused = true

        reset: ->
            @pause()
            @current.album = 0
            @current.track = 0

        next: ->
            return unless @playlist.length
            paused = false
            if @playlist[@current.album].tracks.length > (@current.track + 1)
                @current.track++
            else
                @current.track = 0
                @current.album = (@current.album + 1) % @playlist.length
            @play() if @playing

        previous: ->
            return unless @playlist.length
            paused = false
            if @current.track > 0
                @current.track--
            else
                @current.album = (@current.album - 1 + @playlist.length) % @playlist.length
                @current.track = @playlist[@current.album].tracks.length - 1
            @play() if @playing

    playlist.add = (album) ->
        return unless angular.Array.indexOf(playlist, album) is -1
        playlist.push album

    playlist.remove = (album) ->
        player.reset() if angular.Array.indexOf(playlist, album) is current.album
        angular.Array.remove playlist, album

    audio.addEventListener "ended", (=>
        @$apply player.next
    ), false

    player

angular.service "audio", ($document) ->
    $document[0].createElement("audio")
