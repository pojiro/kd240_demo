defmodule Kd240Demo.Ina260 do
  @moduledoc """
  INA260 module for I2C test

  https://www.ti.com/lit/ds/symlink/ina260.pdf

  ref. register and lsb values are in the PDF p.17
  """

  use GenServer

  @bus "i2c-1"
  @address 0x40

  @current_register 0x01
  @voltage_register 0x02
  @power_register 0x03

  @lsb_ma 1.25
  @lsb_mv 1.25
  @lsb_mw 10.0

  def current(), do: GenServer.call(__MODULE__, :current)
  def voltage(), do: GenServer.call(__MODULE__, :voltage)
  def power(), do: GenServer.call(__MODULE__, :power)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, bus} = Circuits.I2C.open(@bus)
    {:ok, %{bus: bus}}
  end

  def handle_call(:current, _from, state) do
    {:ok, <<raw::16>>} =
      Circuits.I2C.write_read(state.bus, @address, <<@current_register>>, 2)

    {:reply, raw * @lsb_ma / 1000.0, state}
  end

  def handle_call(:voltage, _from, state) do
    {:ok, <<raw::16>>} =
      Circuits.I2C.write_read(state.bus, @address, <<@voltage_register>>, 2)

    {:reply, raw * @lsb_mv / 1000.0, state}
  end

  def handle_call(:power, _from, state) do
    {:ok, <<raw::16>>} =
      Circuits.I2C.write_read(state.bus, @address, <<@power_register>>, 2)

    {:reply, raw * @lsb_mw / 1000.0, state}
  end
end
