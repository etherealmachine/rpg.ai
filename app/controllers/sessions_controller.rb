class SessionsController < ApplicationController
  before_action :set_session, except: %i[ index new create ]

  def index
    @sessions = Session.all
  end

  def show
    #if @session.log.empty?
    #  @session.prompt(nil)
    #end
  end

  def new
    @session = Session.new
  end

  def edit
  end

  def create
    @session = Session.new(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to session_url(@session), notice: "Session was successfully created." }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to session_url(@session), notice: "Session was successfully updated." }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @session.destroy!

    respond_to do |format|
      format.html { redirect_to sessions_url, notice: "Session was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def prompt
    @session.prompt(params[:input])
    respond_to do |format|
      format.html { redirect_to session_url(@session) }
      format.json { render :show, status: :ok, location: @session }
    end
  end

  def clear
    @session.clear!
    respond_to do |format|
      format.html { redirect_to session_url(@session) }
      format.json { render :show, status: :ok, location: @session }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.fetch(:session, {})
    end
end
