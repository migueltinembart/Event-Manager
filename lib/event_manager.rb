require 'pry'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

registration_times = []
# cleans up the zipcode if it does not meet the criteria of 5 digits

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^0-9]/, "")
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11
    phone_number.slice!(0) if phone_number[0] == "1"
    return nil if phone_number[0] != "1"
  end
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def safe_form(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output');

  puts "Hi"
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') {|file| file.puts form_letter}
    
end

def get_time_of_registration(date_and_time)
  begin
    time = date_and_time.split(" ").last
    hour = time.split(":").first.to_i
  rescue
    nil
  end
end



puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv', 
  headers: true, 
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name].capitalize
    
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])

  time = get_time_of_registration(row[:regdate])
  registration_times << time
  puts "#{id} #{name} #{phone_number} #{time}"
  
  #legislators = legislators_by_zipcode(zipcode)

    
  #form_letter = erb_template.result(binding)

  #safe_form(id, form_letter)
end
binding.pry

p  registration_times