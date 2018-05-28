# Hotel Booking Application

Simple hotel booking application

## Requirements
- Ruby 2.4
- Rails 5

## Setup
#### MySQL
- Create user in mysql:
- `mysql -u root`
- `create user 'hotel_root'@'localhost' identified by '2018!';`
- `GRANT ALL PRIVILEGES ON *.* TO 'hotel_root'@'localhost' WITH GRANT OPTION;`
#### Application
- Goto project's directory in your terminal
- Run `bundle install`
- Run `rails db:setup`
- Run `rails db:migrate` It will create required table

## See the application in action
- For now it's a console application
- Start the console using `rails c`

### Partner API
1. Partner Sign Up:
```ruby
Partner.partner_sign_up(name: 'Miyako Hotel Los Angeles', email: 'miyako@test.com')
Partner.partner_sign_up(name: 'Hampton Inn & Suites Thousand Oaks', email: 'hampton@test.com')
```

```ruby
=> Sample response:
{:err=>nil, :err_msg=>{}, :partner=> partner_object}
{:err=>"err1", :err_msg=>{:email=>["Email must be given"]}, :partner=>nil}
```

2. Partner add room:
```ruby
Room.add_room(room_type: '2 full­size beds with a private bath', occupancy: 2, partner_id: 1, total_quantity: 5)
```

```ruby
=> Sample response:
{:err=>nil, :err_msg=>{}, :room=>room object, :inventory=>inventory object}
```

3. Partner adds rate for their room:
```ruby
RoomRate.add_room_rates(partner_id: 1, room_id: 1, start_date: '2018-05-28', end_date: '2018-05-29', rate: 120)
RoomRate.add_room_rates(partner_id: 1, room_id: 1, start_date: '2018-05-30', end_date: '2018-05-31', rate: 140)
RoomRate.add_room_rates(partner_id: 1, room_id: 1, start_date: '2018-06-01', end_date: ‘2018-06-30', rate: 150)
```

=> Once above 3 steps completed, the room inventory status will be marked as active (1) in `inventories` table.

=> After partner hotel adds rate, I have used push mechanism over here to calculate the average monthly rate for the hotel and that will be created/updated in `room_rate_average` table.

=> This method will be invoked after partner adds rate: `RoomRateAverage.calculate_and_update_average_cost(inventory_id: 1)`


### Guest API
1. User Sign Up:
```ruby
User.user_sign_up(email: 'ketan@test.com’)
```

2. User search for hotel room:
```ruby
Room.get_availability(room_id: 1, move_in_date: '2018-05-28', move_out_date: '2018-06-30')
```

```ruby
=> Sample response:
{
    :err=>nil,
    :search_result=>[
        {:hotel_name=>"Hampton Inn & Suites Thousand Oaks", :room_type=>"2 full­size beds with a private bath", :rent=>4561.85, :inventory_id => 4},
        {:hotel_name=>"Miyako Hotel Los Angeles", :room_type=>"2 full­size beds with a private bath", :rent=>5867.56, :inventory_id => 5}
    ]
}
```

3. Booking hotel room by user:
```ruby
Booking.book_room(:user_id => 1, :inventory_id => 4, move_in_date: '2018-05-28', move_out_date: '2018-06-30', booking_quantity: 1)
```

```ruby
=> Sample response:
{:err=>nil, :booking=>booking object}
```