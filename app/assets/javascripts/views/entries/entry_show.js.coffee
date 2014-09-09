class Raffler.Views.EntryShow extends Backbone.View
  template: JST['entries/show']

  render: ->
    $(@el).html(@template( entry: @model ))
    this

  events:
    'click .back': 'back'

  back: ->
    Backbone.history.navigate '/', true
