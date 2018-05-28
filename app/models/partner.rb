class Partner < ApplicationRecord
  has_many :inventories
  has_many :room_rates
  has_many :bookings

  validates :name, presence: { message: 'Name must be given' }
  validates :email, presence: { message: 'Partner email must be given' }

  # Register partner hotel
  #
  # Author:: Ketan
  # Date:: 2018/05/25
  #
  # <b>Expects</b>
  # * <b>params[:name]</b> <em>(String)</em> - Name of the partner hotel
  # * <b>params[:email]</b> <em>(String)</em> - Email contact of the partner hotel
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  # * Hash[:err_msg]: <em>(Hash)</em> - Error field and message array
  # * Hash[:partner]: Partner object
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.partner_sign_up(params)
    response = {err: nil, err_msg: {}, partner: nil}

    partner = Partner.create(
      name: params[:name],
      email: params[:email]
    )

    partner.errors.messages.present? ?
      response.merge!(err: 'err1', err_msg: partner.errors.messages) : response.merge!(partner: partner)

    response
  end
end
