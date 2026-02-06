class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      broadcast_players_list
      redirect_to players_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 2PT shot
  def two_point
    player = Player.find(params[:id])
    player.attempt_two(made: params[:made] == "true")

    broadcast_player(player)
    head :ok
  end

  # 3PT shot
  def three_point
    player = Player.find(params[:id])
    player.attempt_three(made: params[:made] == "true")

    broadcast_player(player)
    head :ok
  end

  # Free throw
  def free_throw
    player = Player.find(params[:id])
    player.attempt_free_throw(made: params[:made] == "true")

    broadcast_player(player)
    head :ok
  end

  # Rebound
  def rebound
    player = Player.find(params[:id])
    player.record_rebound

    broadcast_player(player)
    head :ok
  end

  # Turnover
  def turnover
    player = Player.find(params[:id])
    player.record_turnover

    broadcast_player(player)
    head :ok
  end

  # Block
  def block
    player = Player.find(params[:id])
    player.record_block

    broadcast_player(player)
    head :ok
  end

  # Steal
  def steal
    player = Player.find(params[:id])
    player.record_steal

    broadcast_player(player)
    head :ok
  end

  # Undo last stat event
  def undo
    player = Player.find(params[:id])
    player.undo_last_action

    broadcast_player(player)
    head :ok
  end

  # Reset all players' stats
  def reset
    Player.reset_all_stats!
    broadcast_players_list

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to players_path }
    end
  end

  def destroy
    player = Player.find(params[:id])
    player.destroy

    broadcast_players_list

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to players_path }
    end
  end

  private

  def player_params
    params.require(:player).permit(:name)
  end

  # Broadcast a single player's updated card
  def broadcast_player(player)
    Turbo::StreamsChannel.broadcast_replace_to(
      "players",
      target: view_context.dom_id(player),
      partial: "players/player",
      locals: { player: player }
    )
  end

  # Broadcast the full list (for add/remove/reset)
  def broadcast_players_list
    Turbo::StreamsChannel.broadcast_replace_to(
      "players",
      target: "players",
      partial: "players/players",
      locals: { players: Player.all }
    )
  end
end
