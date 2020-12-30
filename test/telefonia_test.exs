defmodule TelefoniaTest do
  use ExUnit.Case
  doctest Telefonia

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Start" do
    test "deve fazer a criacao dos arquivos prepago e pospago" do
      Telefonia.start()
      {:ok, files} = File.ls()

      assert Enum.find_value(files, fn x -> x == "pre.txt" end) == true
      assert Enum.find_value(files, fn x -> x == "pos.txt" end) == true
    end
  end

  describe "Listar assinantes" do
    test "deve buscar assinantes do tipo prepago e pospago" do
      Telefonia.cadastrar_assinante("Marlon", "123", "123", :prepago)
      Telefonia.cadastrar_assinante("Joao", "456", "456", :pospago)

      assert Telefonia.buscar_assinante("123") ==
               %Assinante{
                 chamadas: [],
                 cpf: "123",
                 nome: "Marlon",
                 numero: "123",
                 plano: %Prepago{creditos: 0, recargas: []}
               }

      assert Telefonia.buscar_assinante("456") ==
               %Assinante{
                 chamadas: [],
                 cpf: "456",
                 nome: "Joao",
                 numero: "456",
                 plano: %Pospago{valor: 0}
               }

      assert Telefonia.listar_assinantes() ==
               [
                 %Assinante{
                   chamadas: [],
                   cpf: "123",
                   nome: "Marlon",
                   numero: "123",
                   plano: %Prepago{creditos: 0, recargas: []}
                 },
                 %Assinante{
                   chamadas: [],
                   cpf: "456",
                   nome: "Joao",
                   numero: "456",
                   plano: %Pospago{valor: 0}
                 }
               ]
    end

    test "deve buscar assinantes do tipo prepago" do
      Telefonia.cadastrar_assinante("Marlon", "123", "123", :prepago)
      Telefonia.cadastrar_assinante("Joao", "456", "456", :pospago)

      assert Telefonia.listar_assinantes_prepago() == [
               %Assinante{
                 chamadas: [],
                 cpf: "123",
                 nome: "Marlon",
                 numero: "123",
                 plano: %Prepago{creditos: 0, recargas: []}
               }
             ]
    end

    test "deve buscar assinantes do tipo pospago" do
      Telefonia.cadastrar_assinante("Marlon", "123", "123", :prepago)
      Telefonia.cadastrar_assinante("Joao", "456", "456", :pospago)

      assert Telefonia.listar_assinantes_pospago() == [
               %Assinante{
                 chamadas: [],
                 cpf: "456",
                 nome: "Joao",
                 numero: "456",
                 plano: %Pospago{valor: 0}
               }
             ]
    end
  end

  test "deve fazer uma recarga" do
    Telefonia.cadastrar_assinante("Marlon", "123", "123", :prepago)

    assert Telefonia.recarga("123", DateTime.utc_now(), 30) ==
             {:ok, "Recarga realizada com sucesso"}
  end

  describe "Fazer chamada" do
    test "deve fazer uma chamada para prepago" do
      Telefonia.cadastrar_assinante("Marlon", "123", "123", :prepago)
      Telefonia.cadastrar_assinante("Joao", "456", "456", :pospago)

      Recarga.nova(DateTime.utc_now(), 30, "123")

      {:ok, msg} = Telefonia.fazer_chamada("123", :prepago, DateTime.utc_now(), 10)
      assert msg == "A chamada custou 14.5, e voce tem 15.5 de creditos"

      {:ok, msg} = Telefonia.fazer_chamada("456", :pospago, DateTime.utc_now(), 10)
      assert msg == "Chamada feita com sucesso! Duracao 10 minutos"
    end
  end

  describe "Imprimir contas" do
    test "deve imprimir a conta dos assinantes prepago e pospago" do
      Telefonia.cadastrar_assinante("Marlon", "123", "123", :pospago)
      Telefonia.cadastrar_assinante("Joao", "456", "456", :prepago)

      Recarga.nova(DateTime.utc_now(), 30, "456")

      data = DateTime.utc_now()
      data_antiga = ~U[2020-12-29 22:17:27.952416Z]
      Telefonia.fazer_chamada("123", :pospago, data, 3)
      Telefonia.fazer_chamada("123", :pospago, data_antiga, 3)
      Telefonia.fazer_chamada("456", :prepago, data, 3)
      Telefonia.fazer_chamada("456", :prepago, data, 3)

      assert Telefonia.imprimir_contas(12, 2020) == :ok
    end
  end
end
