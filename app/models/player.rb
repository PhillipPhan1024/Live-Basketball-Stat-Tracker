class Player < ApplicationRecord
  include ActionView::RecordIdentifier

  require "securerandom"

  has_many :stat_events, dependent: :destroy
  validates :name, presence: true

  before_create :set_public_id

  private

  def set_public_id
    self.public_id ||= SecureRandom.uuid
  end

  public

  # 2PT shot
  def attempt_two(made:)
    gid = SecureRandom.uuid

    transaction do
      self.last_action_gid = gid

      self.fga += 1
      StatEvent.create!(
        player: self,
        action: "fga",
        value: 1,
        group_id: gid
      )

      if made
        self.fgm += 1
        self.points += 2

        StatEvent.create!(
          player: self,
          action: "fgm",
          value: 1,
          group_id: gid
        )

        StatEvent.create!(
          player: self,
          action: "points",
          value: 2,
          group_id: gid
        )
      end

      save!
    end
  end

  # 3PT shot
  def attempt_three(made:)
    gid = SecureRandom.uuid

    transaction do
      self.last_action_gid = gid

      self.fga += 1
      self.three_pa += 1

      StatEvent.create!(player: self, action: "fga", value: 1, group_id: gid)
      StatEvent.create!(player: self, action: "three_pa", value: 1, group_id: gid)

      if made
        self.fgm += 1
        self.three_pm += 1
        self.points += 3

        StatEvent.create!(player: self, action: "fgm", value: 1, group_id: gid)
        StatEvent.create!(player: self, action: "three_pm", value: 1, group_id: gid)
        StatEvent.create!(player: self, action: "points", value: 3, group_id: gid)
      end

      save!
    end
  end

  # Free throw
  def attempt_free_throw(made:)
    gid = SecureRandom.uuid

    transaction do
      self.last_action_gid = gid

      self.fta += 1
      StatEvent.create!(
        player: self,
        action: "fta",
        value: 1,
        group_id: gid
      )

      if made
        self.ftm += 1
        self.points += 1

        StatEvent.create!(
          player: self,
          action: "ftm",
          value: 1,
          group_id: gid
        )

        StatEvent.create!(
          player: self,
          action: "points",
          value: 1,
          group_id: gid
        )
      end

      save!
    end
  end

  # Rebound
  def record_rebound
    gid = SecureRandom.uuid
    transaction do
      self.rebounds += 1

      StatEvent.create!(
        player: self,
        action: "rebounds",
        value: 1,
        group_id: gid
      )

      self.last_action_gid = gid
      save!
    end
  end

  # Turnover
  def record_turnover
    gid = SecureRandom.uuid
    transaction do
      self.turnovers += 1

      StatEvent.create!(
        player: self,
        action: "turnovers",
        value: 1,
        group_id: gid)

      self.last_action_gid = gid
      save!
    end
  end

  # Block
  def record_block
    gid = SecureRandom.uuid
    transaction do
      self.blocks += 1

      StatEvent.create!(
        player: self,
        action: "blocks",
        value: 1,
        group_id: gid
      )

      self.last_action_gid = gid
      save!
    end
  end

  # Steal
  def record_steal
    gid = SecureRandom.uuid
    transaction do
      self.steals += 1
      StatEvent.create!(
        player: self,
        action: "steals",
        value: 1,
        group_id: gid
      )

      self.last_action_gid = gid
      save!
    end
  end

  # Undo last action
  def undo_last_action
    return unless last_action_gid

    group = stat_events.where(group_id: last_action_gid)
    return if group.empty?

    transaction do
      group.each do |event|
        case event.action
        when "fga"       then self.fga       -= event.value
        when "fgm"       then self.fgm       -= event.value
        when "three_pa"  then self.three_pa  -= event.value
        when "three_pm"  then self.three_pm  -= event.value
        when "fta"       then self.fta       -= event.value
        when "ftm"       then self.ftm       -= event.value
        when "points"    then self.points    -= event.value
        when "rebounds"  then self.rebounds  -= event.value
        when "turnovers" then self.turnovers -= event.value
        when "blocks"    then self.blocks     -= event.value
        when "steals"    then self.steals     -= event.value
        end
      end

      %w[
        fga fgm three_pa three_pm
        fta ftm points rebounds turnovers
        blocks steals
      ].each do |stat|
        self[stat] = [ self[stat], 0 ].max
      end

      save!
      group.destroy_all
      update!(last_action_gid: nil)
    end
  end

  # Reset all players' stats
  def self.reset_all_stats!
    transaction do
      # Clear undo history so undo can't undo "previous game"
      StatEvent.delete_all

      # Reset all player stats
      update_all(
        points: 0,
        fga: 0,
        fgm: 0,
        three_pa: 0,
        three_pm: 0,
        fta: 0,
        ftm: 0,
        rebounds: 0,
        turnovers: 0,
        blocks: 0,
        steals: 0,
        last_action_gid: nil,
        updated_at: Time.current
      )
    end

    # Broadcast updated UI for everyone
    # (update_all skips callbacks, so we broadcast manually)
    find_each do |player|
      player.broadcast_replace_to "players",
        target: ActionView::RecordIdentifier.dom_id(player),
        partial: "players/player",
        locals: { player: player }
    end
  end
end
