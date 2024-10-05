defmodule Kd240Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kd240Demo.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Kd240Demo.Worker.start_link(arg)
        # {Kd240Demo.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Kd240Demo.Worker.start_link(arg)
      # {Kd240Demo.Worker, arg},
    ]
  end

  def children(_target) do
    dfx_mgrd() ++
      [
        # Children for all targets except host
        # Starts a worker by calling: Kd240Demo.Worker.start_link(arg)
        # {Kd240Demo.Worker, arg},
      ]
  end

  def target() do
    Application.get_env(:kd240_demo, :target)
  end

  defp dfx_mgrd() do
    dfx_mgrd = "/usr/bin/dfx-mgrd"

    if File.exists?(dfx_mgrd) do
      # nerves_system_kd240 provides `/lib/firmware` as tmpfs
      [
        {MuonTrap.Daemon,
         [
           dfx_mgrd,
           [],
           [
             cd: "/lib/firmware",
             stderr_to_stdout: true,
             log_output: :debug,
             log_prefix: "dfx-mgrd: "
           ]
         ]}
      ]
    else
      []
    end
  end
end
