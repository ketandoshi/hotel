class RoomRateAverage < ApplicationRecord
  class << self

    # Calculate monthly average cost for room for partner hotel and update/create entry
    #
    # Author:: Ketan
    # Date:: 2018/05/28
    #
    # <b>Expects</b>
    # * <b>params[:inventory_id]</b> <em>(Integer)</em> - Id of inventory
    #
    # <b>Returns</b>
    # * Hash[:err]: Error code, if any error
    #
    # <b>Errors</b>
    # * <tt>err1</tt>: Mandatory parameter missing
    #
    def calculate_and_update_average_cost(params)
      inventory_obj = Inventory.where(id: params[:inventory_id]).live.first

      return {err: 'err1'} unless inventory_obj.present?

      room_rates = RoomRate.get_room_rates(
        query_condition: {
          partner_id: inventory_obj.partner_id,
          room_id: inventory_obj.room_id
        }
      )

      monthly_rate_data = {}
      room_rates.each do |room_rate_obj|
        monthly_rate_data[room_rate_obj.rate_day.month] ||= {num_of_days: 0, amount: 0.0}
        monthly_rate_data[room_rate_obj.rate_day.month][:num_of_days] += 1
        monthly_rate_data[room_rate_obj.rate_day.month][:amount] += room_rate_obj.rate_amount.to_f
      end

      existing_rra_objs = RoomRateAverage.where(
        inventory_id: inventory_obj.id,
        rate_month: monthly_rate_data.keys
      ).all.index_by(&:rate_month)

      monthly_rate_data.each do |month_number, cost_details|
        rra_obj = existing_rra_objs[month_number] || RoomRateAverage.new

        rra_obj.inventory_id = inventory_obj.id
        rra_obj.rate_month = month_number
        rra_obj.month_average_rate = (cost_details[:amount]/cost_details[:num_of_days]).to_f
        rra_obj.save!
      end

      return {err: nil}
    end

    def get_month_wise_rent(params)
      response = {}

      RoomRateAverage.where(
        inventory_id: params[:inventory_ids],
        rate_month: (params[:move_in_month]..params[:move_out_month])
      ).all.each do |rra_obj|
        response[rra_obj.inventory_id] ||= {}
        response[rra_obj.inventory_id][rra_obj.rate_month] = rra_obj.month_average_rate.to_f
      end

      response
    end

  end
end
