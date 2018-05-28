class User < ApplicationRecord
  has_many :bookings

  validates :email, presence: { message: 'User email must be given' }

  # Register customer
  #
  # Author:: Ketan
  # Date:: 2018/05/26
  #
  # <b>Expects</b>
  # * <b>params[:email]</b> <em>(String)</em> - Email contact of the user
  #
  # <b>Returns</b>
  # * Hash[:err]: Error code, if any error
  # * Hash[:err_msg]: <em>(Hash)</em> - Error field and message array
  # * Hash[:user]: User object
  #
  # <b>Errors</b>
  # * <tt>err1</tt>: Mandatory parameter missing
  #
  def self.user_sign_up(params)
    response = {err: nil, err_msg: {}, user: nil}

    user = User.create(
      email: params[:email]
    )

    user.errors.messages.present? ?
      response.merge!(err: 'err1', err_msg: user.errors.messages) : response.merge!(user: user)

    response
  end
end
