Code.require_file("example/echo_controller.exs")
Code.require_file("example/topic_controller.exs")
Code.require_file("example/router.exs")
Plug.Adapters.Cowboy.http Router, [], [dispatch: Router.dispatch_table]
