class RoomRate < ApplicationRecord
  belongs_to :partner
  belongs_to :room

  validates :partner_id, numericality: { only_integer: true, greater_than: 0 }
  validates :room_id, numericality: { only_integer: true, greater_than: 0 }
  validates :rate_day, presence: { message: 'Date must be given' }
  validates :rate_amount, numericality: { greater_than: 0 }

  RENT_DAYS = 30

  # Add rates for the partner hotel room
  #
  # Author:: Ketan
  # Date:: 2018/05/25
  #
  # <b>Expects</b>
  # * <b>params[:partner_id]</b> <em>(Integer)</em> - Id of the partner
  # * <b>params[:room_id]</b> <em>(Integer)</em> - Id of the room
  # * <b>params[:start_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  # * params[:end_date] <em>(String)</em> - Date string YYYY-MM-DD format
  # * <b>params[:rate]</b> <em>(Float)</em> - Rate for the room for the day
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  # * Hash[:err_msg]: <em>(Hash)</em> - Error field and message array
  # * Hash[:room_rate]: RoomRate object
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.add_room_rates(params)
    response = {err: nil, err_msg: {}}

    return response.merge(
      err: 'err1',
      err_msg: {start_date: ['Start date must be given']}
    ) unless params[:start_date].present?

    start_date = end_date = DateTime.parse(params[:start_date])
    end_date = DateTime.parse(params[:end_date]) if params[:end_date].present?

    rate_error = false

    room_rates = get_room_rates_between_dates(
      partner_ids: [params[:partner_id].to_i],
      room_id: params[:room_id],
      move_in_date: start_date,
      move_out_date: end_date
    ).index_by(&:rate_day)

    (start_date..end_date).each do |dt|
      rate_obj = room_rates[dt] || RoomRate.new

      rate_obj.rate_day = dt
      rate_obj.rate_day_timestamp = dt.to_i
      rate_obj.partner_id = params[:partner_id].to_i
      rate_obj.room_id = params[:room_id].to_i
      rate_obj.rate_amount = params[:rate].to_f
      success = rate_obj.save

      rate_error = !success

      break if rate_error
    end

    unless rate_error
      inventory_obj = Inventory.get_inventory_for_partner_room(params)
      inventory_obj.make_active
      RoomRateAverage.calculate_and_update_average_cost(inventory_id: inventory_obj.id)
    end

    response
  end

  def self.get_room_rates_between_dates(params)
    params[:move_in_date] = DateTime.parse(params[:move_in_date]) unless params[:move_in_date].is_a?(DateTime)
    params[:move_out_date] = DateTime.parse(params[:move_out_date]) unless params[:move_out_date].is_a?(DateTime)

    get_room_rates(
      query_condition: {
        partner_id: params[:partner_ids],
        room_id: params[:room_id].to_i,
        rate_day_timestamp: (params[:move_in_date]..params[:move_out_date])
      }
    )
  end

  def self.get_room_rates(params)
    RoomRate.where(params[:query_condition]).all
  end

  # Get room rent for the partner hotel for specified dates
  #
  # Author:: Ketan
  # Date:: 2018/05/28
  #
  # <b>Expects</b>
  # * <b>params[:inventory_ids]</b> <em>(Array)</em> - Array of ids of inventory
  # * <b>params[:move_in_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  # * <b>params[:move_out_date]</b> <em>(String)</em> - Date string YYYY-MM-DD format
  #
  # <b>Returns</b>
  # * Array: Ex: [{:inventory_id=>4, :rent=>4561.85}, {:inventory_id=>5, :rent=>5867.56}]
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.get_room_rent(params)
    response = []

    move_in_date = DateTime.parse(params[:move_in_date])
    move_out_date = DateTime.parse(params[:move_out_date])

    month_days = {}
    (move_in_date..move_out_date).each do |dt|
      month_days[dt.month] ||= 0
      month_days[dt.month] += 1
    end

    inventories = Inventory.where(id: params[:inventory_ids]).all.index_by(&:id)

    avg_rates = RoomRateAverage.get_month_wise_rent(
      inventory_ids: params[:inventory_ids],
      move_in_month: move_in_date.month,
      move_out_month: move_out_date.month
    )

    month_rents = {}
    params[:inventory_ids].each do |inv_id|
      month_days.each do |month_num, num_of_days|
        month_rents[inv_id] ||= 0
        month_rents[inv_id] += (num_of_days * avg_rates[inv_id][month_num])
      end

      response << {
        inventory_id: inv_id,
        rent: ((month_rents[inv_id]/month_days.values.sum) * RENT_DAYS).to_f
      }
    end

    response
  end

end
