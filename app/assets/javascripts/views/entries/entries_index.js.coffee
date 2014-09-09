class Raffler.Views.EntriesIndex extends Backbone.View
  template: JST['entries/index']

  initialize: ->
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'add', @appendEntry)

  render: ->
    $(@el).html(@template())
    @collection.each(@appendEntry)
    this

  appendEntry: (entry) =>
    view = new Raffler.Views.Entry( model: entry )
    @$('#entries').append(view.render().el)

  events:
    'submit #new_entry' : 'createEntry'
    'click #draw': 'drawWinner'

  createEntry: (e) ->
    e.preventDefault()
    attr = name: $('#new_entry_name').val()
    @collection.create attr,
      wait: true
      success: -> $('#new_entry').trigger('reset')
      error: @handleError

  drawWinner: (e) ->
    e.preventDefault()
    @collection.drawWinner()

  handleError: (entry, response) ->
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      for attribute, messages of errors
        @$('#errors').html("<p>#{attribute} #{message}</p>") for message in messages
