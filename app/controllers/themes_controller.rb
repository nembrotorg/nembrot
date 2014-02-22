class ThemesController < ApplicationController

  before_action :set_theme, only: [:show, :edit, :update, :destroy]

  # REVIEW: This is not secure
  # See http://factore.ca/on-the-floor/258-rails-4-strong-parameters-and-cancan
  load_and_authorize_resource except: :create
  skip_authorize_resource only: :create

  # GET /themes
  def index
    @themes = Theme.all
  end

  # GET /themes/new
  def new
    @theme = Theme.new
  end

  # GET /themes/1/edit
  def edit
  end

  # POST /themes
  def create
    @theme = Theme.new(theme_params)

    if @theme.save
      redirect_to themes_url, notice: 'Theme was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /themes/1
  def update
    if @theme.update(theme_params)
      redirect_to themes_url, notice: 'Theme was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /themes/1
  def destroy
    @theme.destroy
    redirect_to themes_url, notice: 'Theme was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_theme
    @theme = Theme.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def theme_params
    params.require(:theme).permit(:premium, :public, :css, :effects, :map_style, :name, :typekit_code, :suitable_for_text, :suitable_for_images, :suitable_for_maps, :suitable_for_video_and_sound)
  end

  def set_public_cache_headers
    expires_in 0.minutes, public: false
  end
end
