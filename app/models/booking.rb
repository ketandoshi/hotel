class Booking < ApplicationRecord
  belongs_to :partner
  belongs_to :room
  belongs_to :user

  after_create :after_create_booking

  # Book a hotel room for guest
  #
  # Author:: Ketan
  # Date:: 2018/05/28
  #
  # <b>Expects</b>
  # * <b>params[:user_id]</b> <em>(Integer)</em> - User id
  # * <b>params[:inventory_id]</b> <em>(Integer)</em> - Id of inventory
  # * <b>params[:move_in_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  # * <b>params[:move_out_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  # * <b>params[:booking_quantity]</b> <em>(Integer)</em> - Booking quantity
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  # * Hash[:booking]: Booking object
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.book_room(params)
    response = {err: nil, booking: nil}

    return response.merge(
      err: 'err1',
      err_msg: 'Mandatory parameters are missing'
    ) if params[:move_in_date].blank? || params[:move_out_date].blank? ||
      !(params[:inventory_id].to_i > 0) || !(params[:user_id].to_i > 0) || !(params[:booking_quantity].to_i > 0)

    inventory = Inventory.where(id: params[:inventory_id].to_i).live.first
    return response.merge(
      err: 'err2',
      err_msg: 'Room inventory not available at this moment'
    ) if inventory.blank? || !(inventory.sellable_quantity > 0) ||
          (inventory.sellable_quantity < params[:booking_quantity].to_i)

    availability = Room.get_availability(
      room_id: inventory.room_id,
      move_in_date: params[:move_in_date],
      move_out_date: params[:move_out_date]
    )
    return response.merge(
      err: 'err3',
      err_msg: 'Sorry! room not available at this moment'
    ) if availability[:err].present?

    room_rent = 0
    availability[:search_result].each do |avail_info|
      if avail_info[:inventory_id] == params[:inventory_id].to_i
        room_rent = avail_info[:rent].to_f.round(2)
        break
      end
    end

    booking = Booking.create(
      user_id: params[:user_id].to_i,
      partner_id: inventory.partner_id,
      room_id: inventory.room_id,
      move_in_date: params[:move_in_date],
      move_out_date: params[:move_out_date],
      total_amount: (room_rent * params[:booking_quantity].to_i),
      booked_quantity: params[:booking_quantity].to_i
    )

    response.merge(booking: booking)
  end

  private

  def after_create_booking
    inventory_obj = Inventory.get_inventory_for_partner_room(
      partner_id: self.partner_id,
      room_id: self.room_id
    )

    inventory_obj.booked_quantity = inventory_obj.booked_quantity.to_i + self.booked_quantity
    inventory_obj.save!
  end
end
