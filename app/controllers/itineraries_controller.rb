class ItinerariesController < ApplicationController

  skip_before_action :authenticate_user!, only: [:show]

  before_action :set_itinerary, only: [:show]
  before_action :check_gender, only: [:show]

  before_action :check_permissions

  def new
    @itinerary = Itinerary.new
  end

  def index
    @itineraries = Itinerary.new
  end

  def show
    @conversation = @itinerary.conversations.find_or_initialize_by(user_ids: [current_user.id, @itinerary.user.id]) if current_user
    @reference = current_user.references.find_or_initialize_by(itinerary_id: @itinerary.id) if current_user
    session[:redirect_to] = itinerary_path(@itinerary) unless user_signed_in?
  end

  def create
    @itinerary = current_user.itineraries.new(permitted_params.itinerary)
    if @itinerary.save
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.create') }
    else
      @itinerary.start_address = ''
      @itinerary.end_address = ''
      render :new
    end
  end

  def edit
    @itinerary = current_user.itineraries.find params[:id]
  end

  def update
    @itinerary = current_user.itineraries.find params[:id]
    if @itinerary.update_attributes permitted_params.itinerary
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.update') }
    else
      render :edit
    end
  end

  def destroy
    @itinerary = current_user.itineraries.find params[:id]
    @itinerary.destroy
    redirect_to itineraries_user_path(current_user), flash: { success: t('flash.itineraries.success.destroy') }
  end

  def search
    @selected = Itinerary.find_by(start_address: 'Chennai, India')
    respond_to do |format|
      format.js
    end
  end

  def new_search
    itinerary_entries = params[:itinerary]
    @selected = Itinerary.all
    @selected = @selected.where(start_address: params[:start_address]) unless params[:start_address] == ''
    @selected = @selected.where(end_address: params[:end_address]) unless params[:end_address] == ''
    @selected = @selected.where(pink: true) if params[:toggle_tracker] == 'true' && itinerary_entries[:pink] == '1'
    @selected = @selected.where(round_trip: true) if params[:toggle_tracker] == 'true' && itinerary_entries[:round_trip] == '1'
    @selected = @selected.where(smoking_allowed: true) if params[:toggle_tracker] == 'true' && itinerary_entries[:smoking_allowed] == '1'
    @selected = @selected.where(pets_allowed: true) if params[:toggle_tracker] == 'true' && itinerary_entries[:pets_allowed] == '1'

    respond_to do |format|
      format.js { render 'new_search' }
      format.html { render 'new_search' }
    end
  end

  protected
  def check_permissions
  end

  def set_itinerary
    @itinerary = Itinerary.find params[:id]
  end

  def check_gender
    return unless @itinerary.pink?
    if !user_signed_in?
      redirect_to root_path
    elsif current_user.male?
      redirect_to :dashboard, flash: { error: t('flash.itineraries.error.pink') }
    end
  end
end
