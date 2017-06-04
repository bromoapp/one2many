defmodule One2many.Router do
  use One2many.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", One2many do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/anchor", AnchorController, :index
    get "/audience", AudienceController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", One2many do
  #   pipe_through :api
  # end
end
