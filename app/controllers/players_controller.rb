class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def show
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to players_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 2PT shot
  def two_point
    player = Player.find(params[:id])
    player.attempt_two(made: params[:made] == "true")
    head :ok
  end

  # 3PT shot
  def three_point
    player = Player.find(params[:id])
    player.attempt_three(made: params[:made] == "true")
    head :ok
  end

  # Free throw
  def free_throw
    player = Player.find(params[:id])
    player.attempt_free_throw(made: params[:made] == "true")
    head :ok
  end

  # Rebound
  def rebound
    player = Player.find(params[:id])
    player.record_rebound
    head :ok
  end

  # Turnover
  def turnover
    player = Player.find(params[:id])
    player.record_turnover
    head :ok
  end

  # Block
  def block
    player = Player.find(params[:id])
    player.record_block
    head :ok
  end

  # Steal
  def steal
    player = Player.find(params[:id])
    player.record_steal
    head :ok
  end

  # Undo last stat event
  def undo
    Player.find(params[:id]).undo_last_action
    head :ok
  end

  # Reset all players' stats
  def reset
    Player.reset_all_stats!
    @players = Player.all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "players",
          partial: "players/players",
          locals: { players: @players }
        )
      end
      format.html { redirect_to players_path }
    end
  end

  def new
    @player = Player.new
  end

  def destroy
    @player = Player.find(params[:id])
    @player.destroy

    render turbo_stream: turbo_stream.remove(@player)
  end

  private

  def player_params
    params.require(:player).permit(:name)
  end
end
