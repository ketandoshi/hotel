class Room < ApplicationRecord
  has_many :inventories
  has_many :room_rates
  has_many :bookings

  # Add room for the partner hotel
  #
  # Author:: Ketan
  # Date:: 2018/05/25
  #
  # <b>Expects</b>
  # * <b>params[:partner_id]</b> <em>(Integer)</em> - Id of the partner
  # * <b>params[:room_type]</b> <em>(String)</em> - Type of the room
  # * <b>params[:occupancy]</b> <em>(Integer)</em> - Number of occupancy in the room
  # * <b>params[:total_quantity]</b> <em>(Integer)</em> - Number of rooms available to sale
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  # * Hash[:err_msg]: <em>(Hash)</em> - Error field and message array
  # * Hash[:room]: Room object
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.add_room(params)
    response = {err: nil, err_msg: {}, room: nil}

    valid_res = validate_params(params)

    return response.merge(valid_res) if valid_res[:err].present?

    room = Room.where(room_type: params[:room_type]).first

    unless room.present?
      room = Room.create(
        room_type: params[:room_type],
        occupancy: params[:occupancy]
      )
      response.merge!(err: 'err1', err_msg: {base: ['Something went wrong.']}) if !room.present?
    end

    if room.present?
      response.merge!(room: room)

      inv_result = Inventory.add_inventory(params.merge(room_id: room.id))

      if inv_result[:err].present?
        response.merge!(err_msg: inv_result[:err_msg])
      else
        response.merge!(inventory: inv_result[:inventory])
      end
    end

    response
  end

  def self.validate_params(params)
    res = {err: nil, err_msg: {}}

    msg, field = [], nil

    if !params[:room_type].present?
      field = :room_type
      msg << 'Room type must be given'
    elsif params[:occupancy].to_i <= 0
      field = :occupancy
      msg << 'Occupancy should be numerical'
    elsif params[:partner_id].to_i <= 0 || params[:total_quantity].to_i <= 0
      field = :base
      msg << 'Partner id or inventory is missing.'
    end

    if msg.present?
      res[:err] = 'err1'
      res[:err_msg][field] = msg
    end

    res
  end

  # Add room for the partner hotel
  #
  # Author:: Ketan
  # Date:: 2018/05/25
  #
  # <b>Expects</b>
  # * <b>params[:room_id]</b> <em>(Integer)</em> - Id of the room
  # * <b>params[:move_in_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  # * <b>params[:move_out_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.get_availability(params)
    response = {err: nil, search_result: []}

    return response.merge(
      err: 'err1',
      err_msg: 'Mandatory parameters are missing'
    ) if params[:move_in_date].blank? || params[:move_out_date].blank? || !(params[:room_id].to_i > 0)

    inventories = Inventory.get_available_inventory_for_room(params[:room_id].to_i)

    rate_data = RoomRate.get_room_rent(
      inventory_ids: inventories.collect(&:id),
      move_in_date: params[:move_in_date],
      move_out_date: params[:move_out_date]
    )
    # Eg: [{:inventory_id=>4, :rent=>4561.85}, {:inventory_id=>5, :rent=>5867.56}]

    partner_info = Partner.where(id: inventories.collect(&:partner_id)).all.index_by(&:id)
    room_info = Room.where(id: params[:room_id].to_i).first
    inventory_by_ids = inventories.index_by(&:id)

    rate_data.each do |rate_info|
      response[:search_result] << {
        hotel_name: partner_info[inventory_by_ids[rate_info[:inventory_id]].partner_id].name,
        room_type: room_info.room_type,
        rent: rate_info[:rent].to_f.round(2),
        inventory_id: rate_info[:inventory_id]
      }
    end

    response
  end

end
