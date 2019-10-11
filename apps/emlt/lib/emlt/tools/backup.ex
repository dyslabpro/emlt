defmodule Emlt.Tools.Backup do
  def run() do
    :dets.open_file('neurons-4.dets', type: :set)
    :dets.from_ets('neurons-4.dets', :neurons)
  end
end
