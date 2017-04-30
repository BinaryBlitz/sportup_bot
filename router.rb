require 'tilt'

class Router
  def initialize(request)
    @request = request
  end

  def route
    event = Event.find(path_id) if path_id
    if @request.path == '/events'
      [200, { 'Content-Type' => 'text/html' }, [events_template]]
    elsif @request.path == "/events/#{path_id}" && @request.get?
      [200, { 'Content-Type' => 'text/html' }, [event_template(event)]]
    elsif @request.path == "/events/#{path_id}" && @request.delete?
      event.destroy
      [200, { 'Content-Type' => 'text/html' }, [events_template]]
    end
  end

  def events_template
    Tilt.new('views/events.html.erb').render
  end

  def event_template(event)
    Tilt.new('views/event.html.erb').render(event)
  end

  private

  def path_id
    fragments = @request.path.split("/").reject { |s| s.empty? }
    fragments[1]
  end
end
