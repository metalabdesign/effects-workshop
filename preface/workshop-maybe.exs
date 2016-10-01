defmodule Maybe do
  @moduledoc """
  This is a compact version of the "Maybe" module. The complete code and
  documentation can be found in `maybe.exs`.
  """
  defmodule Just do defstruct [:value] end
  defmodule Nothing do defstruct [] end
  def return(val) when is_nil(val) do %Nothing{} end
  def return(val) do %Just{value: val} end
  def bind(%Just{value: value}, func) do apply(func, [value]) end
  def bind(%Nothing{}, _) do %Nothing{} end
  def mv ~>> func do bind(mv, func) end
end

defmodule RecordService do
  def new_record(name, email, age) do
    %{name: name, email: email, age: age}
  end

  def set_name(%{email: email, age: age}, newName) do
    %{name: newName, email: email, age: age}
  end
  
  def set_email(%{name: name, age: age}, newEmail) do
    %{name: name, email: newEmail, age: age}
  end

  def set_age(%{name: name, email: email, age: age}, newAge) when newAge >= age do
    %{name: name, email: email, age: newAge}
  end

  def set_age(_, _) do
    nil
  end

  def print(%{name: name, email: email, age: age}) do
    IO.puts "------------------------------"
    IO.puts Enum.join(["Name:", name], "")
    IO.puts Enum.join(["Email:", email], "")
    IO.puts Enum.join(["Age:", age], "")
    IO.puts "------------------------------"
  end
end

defmodule RecordExample.Normal do
  def run() do
    rec = RecordService.new_record("Billy", "billy@metalab.co", 31)
    rec = RecordService.set_name(rec, "Billy He")
    rec = RecordService.set_age(rec, 32)
    if rec != nil do
      rec = RecordService.set_email(rec, "billy@metalabdesign.com")
      RecordService.print(rec)
    end
  end
end

RecordExample.Normal.run()

defmodule RecordExample.Maybe do
  import Maybe

  def run() do
    # TODO: Implement the example from RecordExample.Normal using the Maybe Monad
  end
end

RecordExample.Maybe.run()
