# frozen_string_literal: true
class HomesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_home, only: [:show, :edit, :destroy, :update]

  def index
    authorize :home
    @homes = policy_scope(Home)
  end

  def show
    parse_dates

    @readings = @home.readings.take(10)
    @sensors = policy_scope(Sensor).where(home_id: @home.id)

    @temperature = []
    @humidity = []

    @sensors.each do |sensor|
      name = sensor.room_name ? sensor.room_name : 'unnamed'
      @temperature << { name: name, data: temperature_data(sensor, @datesince, @dateto) }
      @humidity << { name: name, data: humidity_data(sensor, @datesince, @dateto) }
    end
  end

  def new
    authorize :home
    @home = Home.new
    @home_types = HomeType.all
  end

  def create
    @home = Home.new(home_params.merge(owner_id: current_user.id))
    authorize @home
    @home.save!
    redirect_to @home
  end

  def edit
    @home_types = HomeType.all
  end

  def update
    @home.update(home_params)
    @home.save!
    redirect_to home_path(@home)
  end

  def destroy
    @home.destroy!
    redirect_to homes_path
  end

  private

  def parse_dates
    @datesince = params[:datesince]
    @dateto = params[:dateto]

    @datesince = 1.day.ago if @datesince.blank?
    @dateto = Date.current if @dateto.blank?
  end

  def home_params
    params[:home].permit(permitted_home_params)
  end

  def permitted_home_params
    %i(
      name
      is_public
      home_type_id
    )
  end

  def temperature_data(sensor, datesince, dateto)
    time_series Reading.temperature, sensor, datesince, dateto
  end

  def humidity_data(sensor, datesince, dateto)
    time_series Reading.humidity, sensor, datesince, dateto
  end

  def time_series(query, sensor, datesince, dateto)
    query.where(sensor: sensor)
         .where(['created_at >= ?', datesince])
         .where(['created_at <= ?', dateto])
         .where('value < 120') # temp hack to filter the bogus readings
         .where('value > 0') # temp hack to filter the bogus readings
         .pluck("date_trunc('minute', created_at)", :value)
  end

  def set_home
    @home = policy_scope(Home).find(params[:id])
    authorize @home
  end
end
