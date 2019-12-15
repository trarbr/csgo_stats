defmodule CsgoStats.ServerCommunicator.InstanceTest do
  use ExUnit.Case, async: true

  alias CsgoStats.ServerCommunicator.Instance

  describe "Can get server instance" do
    test "Domain and port seperate" do
      %Instance{
        ip_address: {_, _, _, _},
        ip_addresses: [{_, _, _, _}],
        ip_index: 0,
        port: 5000
      } = Instance.new("google.dk", 5000)
    end

    test "Domain and port combined" do
      %Instance{
        ip_address: {_, _, _, _},
        ip_addresses: [{_, _, _, _}],
        ip_index: 0,
        port: 5000
      } = Instance.new("google.dk:5000")
    end

    test "ip and port seperate" do
      %Instance{
        ip_address: {192, 168, 1, 5},
        ip_addresses: [{192, 168, 1, 5}],
        ip_index: 0,
        port: 5000
      } = Instance.new("192.168.1.5", "5000")
    end

    test "Domain and port combined" do
      %Instance{
        ip_address: {192, 168, 1, 5},
        ip_addresses: [{192, 168, 1, 5}],
        ip_index: 0,
        port: 5000
      } = Instance.new("192.168.1.5:5000")
    end
  end
end
