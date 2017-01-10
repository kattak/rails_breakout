## Practice with RAILS AJAX, Nested Routes, Partials

*Questions - pending and answered*
 
-What are in the parameters of a nested form?

For this nested form in songs/_form.html.erb:
```ruby
<%= form_for([playlist, song], remote:true, html: {class: "red"}) do |f| %>
  <%= f.text_field :title, placeholder: "title" %>
  <%= f.text_field :artist, placeholder: "artist" %>
  <%= f.submit %>
<% end %>
```

These are the params in songs#create
```bash
  Parameters: {"utf8"=>"✓", "song"=>{"title"=>"Hey Jude", "artist"=>"Beatles"}, "commit"=>"Create Song", "playlist_id"=>"2"}
```
* playlist_id is available
* @playlist is not available in songs#create
(* but can be created with @playlist = Playlist.find(params[:playlist_id])

- Because of t.references playlist in songs migration>>>
  -> Can use playlist AND playlist_id ?!
  
  * Uses playlist in seed
```ruby
party = Playlist.create!(name: "Party Jams")
Song.create!(title: "Collide", artist: "Satchmode", playlist: party)
```
    * Uses playlist_id in create
```ruby 
    @song = Song.new(song_params.merge(playlist_id: params[:playlist_id]))
    .
    .
    .
      private

  def song_params
    params.require(:song).permit(:title, :artist)
  end
```
  * Alternative method 
  ```ruby
  playlist = params[:playlist_id]
  playlist.songs << Song.new(song_params)
  ```
  ** Does this work?


### Migrations
- Create new Rails applications with psql database.
- Playlists have a name and have many songs.
- Songs have a title, artist, and belong to a playlist.
- Ensure you are not entering null values for these attributes. 
- Null value ok for playlist
```ruby
class CreateSongs < ActiveRecord::Migration[5.0]
  def change
    create_table :songs do |t|
      t.string :title, null: false
      t.string :artist, null: false
      t.references :playlist
      t.timestamps
    end
  end
end
```


### Models
-A playlist has many songs
-A song belongs to one playlist

-Validate presence.
```ruby
class Playlist < ApplicationRecord
  has_many :songs

  validates :name, presence: true
end
```

### Seed Data
```ruby 
morning = Playlist.create!(name: "Morning Songs")
party = Playlist.create!(name: "Party Jams")

Song.create!(title: "Your hand in mine", artist: "Explosions in the Sky", playlist: morning)
Song.create!(title: "Collide", artist: "Satchmode", playlist: party)
```

### Check models in rails console
```irb 
rails c

Playlist.all
Song.all

Playlist.all.first.songs
Song.all.first.playlist
```

### Routes
In config/routes.rb
-Can see all playlists
-Can see a playlist with all of its songs and add a new song 
- Set root to see all playlists
```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :playlists, only: [:index, :show] do
    resources :songs, only: [:create]
  end

  # resources :songs, only: [:destroy]
  get '/all_playlists' => "playlists#index"

  root "playlists#index"
end
```

*NB only the external resources have a do...end
*nested resources can also have routes outside of its do...end loop

### Views
Playlists 
-index 
  - renders collection of @playlists
  
-show
 - renders collection of @playlist.songs
 - renders form for creating a new song, passes in locals playlist and song 
 
 ### Make song form submit an AJAX response
 
 In SongsController#create
 ```ruby
     if @song.save
      respond_to do |format|
        format.js {}
 ```
 
 **What does format.js {} mean? **
 > File: songs/create.js.erb
 > has access to @song from SongsController#create
```javascript
$("ul").append("<%= j render partial: 'song', locals: {song: @song} %>");
```
 
 
 ###Error
  > File: songs/error.js.erb
   > has access to @song from SongsController#create
   
   >To render in SongsController#create
 ```ruby
     if @song.save
      respond_to do |format|
        format.js {}
    #    format.json { render json: @song }
      end
    else
      respond_to do |format|
        format.js { render :error, status: 422}
      end
    end
 ```

> Can access @song.errors.full_messages
```javascript
console.log("<%= j @song.errors.full_messages %>")
```
