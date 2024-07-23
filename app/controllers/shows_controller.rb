class ShowsController < ApplicationController
  before_action :find_show, only: %i[show]
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    if params[:query].present?
      # Show.reindex
      # @shows = Show.search(params[:query], fields: [:name], match: :word_start)
      sql_query = 'name ILIKE :query OR summary ILIKE :query'
      @shows = Show.where(sql_query, query: "%#{params[:query]}%")
    else
      @shows = Show.all
    end
    @streaming = {}
    @shows.each do |show|
      JSON.parse(show.streaming.gsub('=>', ':')).each do |service|
        @streaming[service.keys[0]] = service.values[0].values[0].values[0]
      end
    end
  end

  # def autocomplete
  #   render json: Show.search(params[:query], {
  #     fields: ["name^5"],
  #     match: :word_start,
  #     limit: 10,
  #     load: false,
  #     misspellings: {below: 5}
  #   }).map(&:name)
  # end

  def show
    @streaming = {}
    JSON
      .parse(@show.streaming.gsub('=>', ':'))
      .each do |service|
        @streaming[service.keys[0]] = service.values[0].values[0].values[0]
      end
    @followed_show = FollowedShow.new
    @user = current_user
    progress =
      Progress
      .where(user: current_user)
      .select { |prog| prog.episode.show == @show }
    @percentage = []
    (1..@show.number_of_seasons).each do |n|
      season_progress = progress.select { |prog| prog.episode.season_number == n }
      if season_progress.empty?
        season_progress = -1
      else
        season_progress = season_progress.last.episode.episode_number
      end
      @percentage[n] =
        (
          100 *
            [0, season_progress].max.fdiv(
              @show.episodes.where(season_number: n).count
            )
        )
    end
    @review = Review.new
    @reviews = Review.where(show: @show)
    @season_summaries = {}
    (1..@show.number_of_seasons).to_a.each do |n|
      @season_summaries[n] = @show.season_summaries.find_by(season_number: n).summary
    end
  end

  # def new

  # end

  # def create

  # end

  # def edit
  # end

  # def update
  #   # @show = Show.find(params[:id])
  #   # if @show.update(show_params)
  #   #   redirect_to show_path(@show)
  #   # else
  #   #   render :edit
  #   # end
  # end

  # def destroy
  # @show = Show.find(params[:id])
  # redirect_to show_path
  # end

  # def details
  #   # @show = Show.find(params[:id])
  # end

  private

  def show_params
    params
      .require(:show)
      .permit(:name, :summary, :number_of_seasons, :rating, :photo, :streaming)
  end

  def find_show
    Rails.logger.info("Params: #{params.inspect}")
    @show = Show.find(params[:id])
  end
end
