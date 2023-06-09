defmodule WavyBirdWeb.Router do
  use WavyBirdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WavyBirdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WavyBirdWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/web/sandbox", PageController, :web_sandbox
    get "/web/sandbox/http", PageController, :web_http_sandbox
    live "/tools", ToolsLive.Index
    live "/hn/jobs", HnJobsLive.Index
    live "/web/sandbox/websocket", WebSandboxLive.Websocket
  end

  scope "/api", WavyBirdWeb do
    pipe_through :api

    get "/get", HttpController, :echo
    post "/post", HttpController, :echo
    put "/put", HttpController, :echo
    patch "/patch", HttpController, :echo
    delete "/delete", HttpController, :echo
    head "/head", HttpController, :echo

    get "/status/:code", HttpController, :status
    post "/status/:code", HttpController, :status
    put "/status/:code", HttpController, :status
    patch "/status/:code", HttpController, :status
    delete "/status/:code", HttpController, :status

    get "/delay/:seconds", HttpController, :delay

    post "/cookie/set/:key/:value", HttpController, :set_cookie
    delete "/cookie/remove/:delete", HttpController, :remove_cookie
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:wavy_bird, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
