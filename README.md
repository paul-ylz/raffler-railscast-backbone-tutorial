# Notes on learning Backbone.js from Railscasts episode #323 and #325

## [Railscasts episode 323][cast]

#### Getting my head around Backbone.js architecture. 
So far I've got an idea for Backbone through [Codeschool's][codeschool] Anatomy of Backbone 1 & 2. Working alongside these 2 Railscasts has been a great next step.  

1. __Main Backbone app__
`window.Raffler`  
`app/assets/javascripts/raffler.js.coffee`  
The main app file. Namespaces our backbone app. Initializes it.  Initialization means that it starts the history and __instantiates router__.

2. __Entries router__
`Raffler.Routers.Entries`  
`app/assets/javascripts/routers/entries_router.js.coffee`  
Sets routes. Fetches collections or models. When the route is called, the router __instantiates a view__, passing the collection into it, and rendering it into the DOM via the `#container` div.  

3. __Entries view__
`Raffler.Views.EntriesIndex`  
`app/assets/javascripts/views/entries/entries_index.js.coffee`  
Specifies a template. Renders that template with the data that was passed from the router, placing the rendered contents in view's `el` property.  
In `@collection.on('reset', @render, this)`, `reset` would not get fired by `@collection.fetch()` anymore as of Backbone 1.1 (see [change log][changelog]). The quickest fix is to use `Collection.fetch({ reset: true })`.

4. __template__
`JST['entries/index']`  
`app/assets/templates/entries/index.jst.eco`  

        <% for entry in @entries.models: %>
          <li><%= entry.get('name') %></li>
        <% end %>

## [Railscasts episode 325][cast2]

1. __Creating resources__  
   Creating resources starts with an html form. We listen for the __event__ from the __view__. When a users clicks 'Add' or presses `Enter` on the form with form id `#new_entry`, the event triggered is `'submit #new_entry'`. The view's `events` hash routes this event to a function we call `CreateEntry`, which takes the argument `event`.  

2. `CreateEntry: (event) ->`  
   Create the new resource via its collection with `@collection.create`, giving it the params grabbed from the element `name: $('#new_entry_name').val()`.

3. __Updating the view__  
   Update the view by listening to the collection for its 'add' event. `@listenTo(@collection, 'add', @appendEntry)`. The `appendEntry` function instantiates a new `Raffler.Views.Entry`, passing it the newly created resource before appending the new view into the `#entries` element in its own `el`.  

   I'm not sure exactly why, but there is an issue with context here, and `appendEntry` needs to have an explicit `this` context provided. In Coffee this is done by defining the function with the fat arrow `=>`. In plain js, `this` is passed as the last argument.  

4. __Updating the view - a refinement__  
   Here we want to be able to append a new item rather than re-render the entire view when the item is added. First we make a new view and a new template for an individual entry.  
   `/app/assets/views/javascripts/entries/entry.js.coffee`  
   `/app/assets/templates/entries/entry.jst.eco`  
   In the index view's `render` function, we loop through the collection and call `appendEntry` for each one.  

5. __Passing server side validations to the front-end__  
   `Collection.create` has callback hooks for `success` and `error`. On success, we reset the form to clear the old input value. On error, we call `handleError` to display the server's error message on the DOM. To do this, first we check `response.status == 422`, then we use jQuery's `$.parseJSON` to get the message values and add them to an `#error` div.  
   There remains an issue that the collection's `add` event has already been fired before server validations have returned, and `appendEntry` has been called with an empty model. To prevent this, we add the param `wait: true` on `Collection.create`.  

6. __Drawing a winner__  
   Put the click listener in the EntriesIndex view's events hash.  
   `'click #draw': 'drawWinner'`  
   `@drawWinner` calls drawWinner function on the collection `@collection.drawWinner()`  
   In the collection we `shuffle()` the contents and grab the first one to be our winner, updating its attributes to `winner: true`.  
   We update `entry.jst.eco` so that if `winner: true`, we'll add 'WINNER' next to the entry's name, and we'll put a class on it so we can style it or highlight it later.  

         <% if @entry.get('winner'): %>
           <span class="winner">WINNER</span>
         <% end %>

   The `:` added to the end of the if statement is for dealing with Coffee's whitespace sensitivity.  

7. __Updating the view with 'winner'__  
   In the `entry` view, we listen to the model for its change event to trigger its render function with the updated model.  

8. __Highlighting the latest winner__  
   After updating the winner model, we'll trigger a custom event.  
   `winner.trigger('highlight')`  
   Returning to the `Entry` view, we listen to the model for that 'highlight' event to call our `highlightWinner` function.  
   `@highlightWinner` then calls `addClass(.highlight)` on the latest winning entry (and `removeClass(.highlight)` on any other winners in the DOM.)  

9.  __Refining and refactoring__  
   The `drawWinner` function, defined on the collection class, makes several calls on the winner model, so we refactor that code into the `Entry` model instead. For this to work, the collection class must have the model hash defined and pointing to `Raffler.Models.Entry`.  

10. __Bootstrapping__  
   We currently call `fetch()` on the collection after instantiating it in the router, causing an additional call to the server. To reduce that to a single call, we can put the JSON data in the DOM instead using a html5 `data` attribute. To get the data into the DOM, we use this code in the Rails view:  
   `<%= content_tag 'div', 'Loading...', id: 'container', data: { entries: Entry.all } %>`  
   Then in the router, after constructing our collection we can call `@collection.reset($('#container').data 'entries')` instead of `.fetch()`.  
   For this refinement to work, we need to tweak our `appendEntry` function in the collection. Written this way: `$('#entries').append(view.render().el)`, the code does not work because `appendEntry` is getting called before the #entries container has been inserted into the DOM. We have to add an `@` to the start of that line so that it looks inside its `el` for the #entries container instead of trying to find it in the DOM. Lesson in scoping: Go through the view, not the DOM. There is still another scope issue because `appendEntry` is called from `@collection` and not `@`, therefore the scope of `this` is changed in `appendEntry`. Hence, `appendEntry` needs to be defined with a fat arrow.  

## Other things learnt along the way
- __Inspecting server response errors in Chrome.__  
`Developer Tools -> Network` Click on 4xx response, preview tab.  
Why did that take so long to figure out?!

- __Resetting forms with jQuery.__  
  Ryan Bates used the jquery syntax:  
  `$('#new_entry')[0].reset()`  

  Standard Javascript syntax:  
 `getElementById('#new_entry').reset();`  

  jQuery blog suggests  
  `$('#new_entry').trigger('reset')`  


## Links
- [Backbone.js][bbjs]
- [Backbone-on-rails gem'][borgem]
- [Eco templating][eco]
- [Railscast episode 323: Backbone on rails pt. 1][cast]
- [Railscast episode 325: Backbone on rails pt. 2][cast2]

[borgem]: https://github.com/meleyal/backbone-on-rails
[cast]: http://railscasts.com/episodes/323-backbone-on-rails-part-1
[cast2]: http://railscasts.com/episodes/325-backbone-on-rails-part-2
[eco]: https://github.com/sstephenson/eco
[codeschool]: https://www.codeschool.com/courses/anatomy-of-backbone-js
[bbjs]: http://documentcloud.github.io/backbone/
[changelog]: http://backbonejs.org/#changelog