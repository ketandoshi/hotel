class Inventory < ApplicationRecord
  belongs_to :partner
  belongs_to :room

  validates :partner_id, numericality: { only_integer: true, greater_than: 0 }
  validates :room_id, numericality: { only_integer: true, greater_than: 0 }
  validates :total_quantity, numericality: { only_integer: true, greater_than: 0 }

  scope :live, -> { where(status: 1) }

  class << self
    # Add inventory for the partner hotel room
    #
    # Author:: Ketan
    # Date:: 2018/05/25
    #
    # <b>Expects</b>
    # * <b>params[:partner_id]</b> <em>(Integer)</em> - Id of the partner
    # * <b>params[:room_id]</b> <em>(Integer)</em> - Id of the room
    # * <b>params[:total_quantity]</b> <em>(Integer)</em> - Number of rooms available to sale
    #
    # <b>Returns</b>
    # * Hash[:err]: Error code, if any error
    # * Hash[:err_msg]: <em>(Hash)</em> - Error field and message array
    # * Hash[:inventory]: Inventory object
    #
    # <b>Errors</b>
    # * <tt>err1</tt>: Mandatory parameter missing
    #
    def add_inventory(params)
      response = {err: nil, err_msg: {}, inventory: nil}

      inventory = Inventory.create(
        partner_id: params[:partner_id].to_i,
        room_id: params[:room_id].to_i,
        total_quantity: params[:total_quantity].to_i
      )

      inventory.errors.messages.present? ?
        response.merge!(err: 'err1', err_msg: inventory.errors.messages) : response.merge!(inventory: inventory)

      response
    end

    def get_inventory_for_partner_room(params)
      Inventory.where(
        partner_id: params[:partner_id].to_i,
        room_id: params[:room_id].to_i
      ).first
    end

    def get_live_inventory_for_room(params)
      Inventory.where(
        room_id: params[:room_id].to_i
      ).live.all
    end

    def get_available_inventory_for_room(room_id)
      inventories = []

      get_live_inventory_for_room(room_id: room_id).each do |inv_obj|
        next unless inv_obj.sellable_quantity > 0
        inventories << inv_obj
      end

      inventories
    end
  end

  def make_active
    self.status = 1
    self.save!
  end

  def sellable_quantity
    (self.total_quantity - self.booked_quantity.to_i)
  end
end
