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

  private

  def playlist_params
    params.require(:playlist).permit(:name)
  end
end
