require 'json'


MyApp.add_route('GET', '/api/v1/health', {
  "resourcePath" => "/Health",
  "summary" => "Health check",
  "nickname" => "health_check", 
  "responseClass" => "void", 
  "endpoint" => "/health", 
  "notes" => "Health check",
  "parameters" => [
    ]}) do
  cross_origin
  # the guts live here

  {"status"=> 200, "message" => "healthy"}.to_json
end

