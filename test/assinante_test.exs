defmodule AssinanteTest do
  use ExUnit.Case
  doctest Assinante

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "testes resposaveis pelo cadastro de assinantes" do
    test "deve retornar uma struct de assinante" do
      assert %Assinante{nome: "Teste", numero: "123", cpf: "123", plano: :pospago}.nome ===
               "Teste"
    end

    test "deve cadastar um usuario prepago" do
      assert Assinante.cadastrar("Marlon", "123", "123", :prepago) ==
               {:ok, "Assinante Marlon cadastrado com sucesso"}
    end

    test "deve retornar erro dizendo que o assinante ja esta cadastrado" do
      Assinante.cadastrar("Marlon", "123", "123", :prepago)

      assert Assinante.cadastrar("Marlon", "123", "123", :prepago) ==
               {:error, "Assinante com este numero Cadastrado!"}
    end
  end

  describe "testes responsaveis pela busca de assinantes" do
    test "buscar assinante pospago" do
      Assinante.cadastrar("Marlon", "123", "123", :pospago)
      assert Assinante.buscar_assinante("123", :pospago).nome === "Marlon"
      assert Assinante.buscar_assinante("123", :pospago).plano.__struct__ === Pospago
    end

    test "buscar assinante prepago" do
      Assinante.cadastrar("Marlon", "123", "123", :prepago)
      assert Assinante.buscar_assinante("123", :prepago).nome === "Marlon"
    end
  end

  describe "delete" do
    test "deve deletar um assinante" do
      Assinante.cadastrar("Marlon", "123", "123", :prepago)
      Assinante.cadastrar("Joao", "333", "123234", :prepago)
      assert Assinante.deletar("123") == {:ok, "Assinante Marlon deletado!"}
    end
  end
end
