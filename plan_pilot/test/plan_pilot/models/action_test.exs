defmodule PlanPilot.Models.ActionTest do
  use PlanPilot.DataCase, async: true

  alias PlanPilot.Models.Action
  doctest Action

  test "Return an empty summary on an unknown student" do
    assert [] == Action.summary("Student", "999")
  end

  test "Add actions and then get a summary for an entity" do
    assert [] == Action.summary("Student", "148")

    Action.add("create_student", "Student", "148")
    Action.add("add_course", "Student", "148", %{"summary" => "Added course 99"})
    Action.add("remove_course", "Student", "1234", %{"summary" => "Removed course 33"})

    assert ["create_student", "add_course (Added course 99)"] == Action.summary("Student", "148")
    assert ["remove_course (Removed course 33)"] == Action.summary("Student", "1234")
  end

  test "Add actions and then get details for an entity" do
    assert [] == Action.summary("Student", "148")

    Action.add("create_student", "Student", "148")
    Action.add("add_course", "Student", "148", %{"summary" => "Added course 99", "d" => 99})
    Action.add("remove_course", "Student", "1234", %{"summary" => "Removed course 33", "d" => 33})

    assert [{"create_student", %{}}, {"add_course", %{"summary" => "Added course 99", "d" => 99}}] ==
             Action.details("Student", "148")

    assert [{"remove_course", %{"summary" => "Removed course 33", "d" => 33}}] ==
             Action.details("Student", "1234")
  end

  test "add tuple in the data" do
    a = Action.add("create_student", "Student", "148", %{reply: {:ok, :message}})
    assert a.data == %{"reply" => ["ok", "message"]}
  end
end
