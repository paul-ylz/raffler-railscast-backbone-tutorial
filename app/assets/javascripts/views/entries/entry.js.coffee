class Raffler.Views.Entry extends Backbone.View
  template: JST['entries/entry']
  tagName: 'li'

  events:
    'click': 'showEntry'

  showEntry: ->
    Backbone.history.navigate "entries/#{@model.get('id')}", true

  render: ->
    $(@el).html(@template( entry: @model ))
    this

  initialize: ->
    @listenTo(@model, 'change', @render)
    @listenTo(@model, 'highlight', @highlightWinner)

  highlightWinner: ->
    $('.winner').removeClass('highlight')
    @$('.winner').addClass('highlight')