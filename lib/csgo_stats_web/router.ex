defmodule CsgoStatsWeb.Router do
  use CsgoStatsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CsgoStatsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CsgoStatsWeb do
    pipe_through :browser

    live "/", MatchLive.Index, :index
    live "/matches/:id", MatchLive.Show, :show
  end

  scope "/api", CsgoStatsWeb do
    pipe_through :api

    post "/logs", LogController, :create
  end
end
