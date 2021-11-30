class FollowedShowsController < ApplicationController
  before_action :find_show, only: [:new, :create]

  def new
    @followed_show = FollowedShow.new
  end

  def create
    @followed_show = FollowedShow.new
    @followed_show.show = @show
    @followed_show.user = current_user
    if @followed_show.save
      future_airing = check_air_date(@followed_show)
      p future_airing
      future_airing.each do |episode|
        notification = Notification.create!(
          episode_id: episode.id,
          user_id: current_user.id
        )
      end
      raise
    end
  end

  def destroy
    FollowedShow.destroy(params[:id])
    redirect_to account_path
  end

  private

  def find_show
    @show = Show.find(params[:followed_show][:show_id])
  end

  def check_air_date(followed_show)
    p followed_show.show.episodes
    followed_show.show.episodes.select { |episode| episode.airing_date >= Date.today }
  end
end
