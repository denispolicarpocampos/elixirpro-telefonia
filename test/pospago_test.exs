defmodule PospagoTeste do
  use ExUnit.Case

  doctest Pospago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "deve testar a estrutura para cobertura de testes" do
    assert %Pospago{valor: 30}.valor == 30
  end

  test "deve fazer uma ligacao" do
    Assinante.cadastrar("Marlon", "123", "123", :pospago)

    assert Pospago.fazer_chamada("123", DateTime.utc_now(), 5) ==
             {:ok, "Chamada feita com sucesso! Duracao 5 minutos"}
  end

  test "deve imprimir a conta do assinante" do
    Assinante.cadastrar("Marlon", "123", "123", :pospago)
    data = DateTime.utc_now()
    data_antiga = ~U[2020-06-29 22:17:27.952416Z]
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data_antiga, 3)
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data, 3)

    assinante = Assinante.buscar_assinante("123", :pospago)

    assert Enum.count(assinante.chamadas) == 4

    assinante = Pospago.imprimir_conta(data.month, data.year, "123")

    assert assinante.numero == "123"
    assert Enum.count(assinante.chamadas) == 3
    assert assinante.plano.valor == 12.599999999999998
  end
end
