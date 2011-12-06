
describe "my tunes app", ->

    beforeEach ->
        browser().navigateTo "../../../index.html"
        #pause()

    afterEach ->
        #pause()

    describe "albums", ->
        it "should be displayed", ->
            expect(repeater('ul.albums li.album').count()).toBe 2