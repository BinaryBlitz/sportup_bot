require 'tilt'

class Router
  def initialize(request)
    @request = request
  end

  def route
    case @request.path
    when '/events'
      [200, { 'Content-Type' => 'text/html' }, [events_template]]
    when "/events/#{path_id}"
      event = Event.find(path_id)
      [200, { 'Content-Type' => 'text/html' }, [event_template(event)]]
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
