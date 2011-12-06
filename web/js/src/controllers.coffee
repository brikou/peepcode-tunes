
"use strict"

TunesCtrl = ($xhr, @player) ->
    $xhr "GET", "albums.json", (code, response) =>
        @albums = response

TunesCtrl.$inject = [ "$xhr", "player" ]
