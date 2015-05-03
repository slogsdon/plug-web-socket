# WebSocket

An exploration into a stand-alone library for
Plug applications to easily adopt WebSockets.

## Viewing the examples

Run these:

```
$ git clone https://github.com/slogsdon/plug-web-socket
$ cd plug-web-socket
$ mix deps.get
$ iex -S mix
```

Go here: <http://localhost:4000>.

You will be presented with a list of possible
examples/tests that use a WebSocket connection.

## Integrating with Plug

If you're looking to try this in your own test
application, do something like this:

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use WebSocket.Macro

  # WebSocket routes
  socket "/topic", MyApp.TopicController, :handle
  socket "/echo",  MyApp.EchoController,  :echo

  # Rest of your router's plugs and routes
  # ...
end
```

For the time being, there is a `run/1` function
generated for your router that starts a HTTP/WS
listener. Not sure if this will stay or get
reduced to helper functions that aid in the
creation of a similar function. Most likely the
latter will win out to help compose functionality.
The big part that it plays is the building of a
dispatch table to pass as an option to Cowboy that
has an entry for each of your socket routes and a
catch all for HTTP requests.

## License

WebSocket is released under the MIT License.

See [LICENSE](https://github.com/slogsdon/plug-web-socket/blob/master/LICENSE) for details.
