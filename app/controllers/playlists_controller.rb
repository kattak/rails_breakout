class PlaylistsController < ApplicationController

  def index
    @playlists = Playlist.all
  end

  def show
    @playlist = Playlist.find_by(id: params[:id])
  end

  def create
    @playlist = Playlist.new(playlist_params)
    if @playlist.save
      respond_to do |format|
        format.js {}
      end
    end
  end

  def update
    @playlist = Playlist.find(id: params[:id])
    if @playlist.update(playlist_params)
      respond_to do |format|
        format.js {}
      end
    end
  end


  def destroy
    p params
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
    redirect_to playlists_path
  end

  private

  def playlist_params
    params.require(:playlist).permit(:name)
  end

end
