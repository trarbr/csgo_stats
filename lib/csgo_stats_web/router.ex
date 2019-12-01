defmodule CsgoStatsWeb.Router do
  use CsgoStatsWeb, :router

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

  scope "/", CsgoStatsWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", CsgoStatsWeb do
    pipe_through :api

    post "/logs", LogController, :create
  end
end
