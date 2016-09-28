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
    rec = return(RecordService.new_record("Billy", "billy@metalab.co", 31))
    
    rec = bind(rec, fn record ->
      return(RecordService.set_name(record, "Billy He"))
    end)

    rec ~>> fn record ->
      return(RecordService.set_age(record, 32))
    end ~>> fn record ->
      return(RecordService.set_email(record, "billy@metalabdesign.com"))
    end ~>> fn record ->
      return(RecordService.print(record))
    end
  end
end

RecordExample.Maybe.run()

defmodule RecordExample.FunctionalMaybe do
  import Maybe

  def set_name(newName) do
    fn record ->
      return(RecordService.set_name(record, newName))
    end
  end

  def set_email(newEmail) do
    fn record ->
      return(RecordService.set_email(record, newEmail))
    end
  end

  def set_age(newAge) do
    fn record ->
      return(RecordService.set_age(record, newAge))
    end
  end

  def print() do
    fn record ->
      return(RecordService.print(record))
    end
  end

  def run() do
    rec = return(RecordService.new_record("Billy", "billy@metalab.co", 31))

    rec ~>> set_name("Billy He")
        ~>> set_age(32)
        ~>> set_email("billy@metalabdesign.com")
        ~>> print()
  end
end

RecordExample.FunctionalMaybe.run()
