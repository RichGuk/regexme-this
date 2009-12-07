require 'rubygems'
require 'sinatra'
require 'environment'
# not_found do
#   'Not found'
# end

get '/' do
  haml :home
end

get '/quickref' do
  unless Regex::Tester::SUPPORTED_LANGUAGES.include?(params[:language])
    not_found
  end
  haml :"quick_ref/#{params[:language]}", :layout => false
end

post '/test' do
  begin
    tester = Regex::Tester.new(params[:language])

    # Are they python options? Which are checkboxes =)
    if params[:language] == 'python' && params[:regex_options_python]
      options = params[:regex_options_python].join(',')
    end
    options ||= params[:regex_options]

    case params[:method]
    when 'match'
      tester.match(params[:regex], params[:data], options)
    when 'match_all'
      tester.match_all(params[:regex], params[:data], options)
    when 'replace'
      tester.replace(params[:regex], params[:data], params[:replace_data],
        options)
    end.to_json

  rescue Regex::Errors::MatchException => e
    puts "Error in regex test: #{e}"
    status 400
    'A problem occured!'
  end
end