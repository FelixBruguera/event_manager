require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


puts 'Event Manager Initialized!'

def clean_zip(zipcode)
    zipcode.to_s.rjust(5,'0')
end

def get_legislators(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyDZbTDZHnrh4gu0NjCN88kv5jOMa93CFBw'
    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
    return legislators
end

def save_letter(id,letter)
    Dir.mkdir('output') unless Dir.exist?('output')
    file_name = "output/thanks_#{id}.html"
    File.open(file_name,'w') do |file|
        file.puts letter
    end
end

template = File.read('form_letter.erb')
erb_template = ERB.new template
lines = CSV.open('event_attendees.csv',headers: true, header_converters: :symbol)
lines.each do |line|
    id = line[0]
    name = line[:first_name]
    zip = clean_zip(line[:zipcode])
    legislators = get_legislators(zip)
    form_letter = erb_template.result(binding)
    save_letter(id,form_letter)
end
